#!/usr/bin/env php
<?php

/**
 * gsxlib/gsxcl
 * A test package and command line client to the GSX library
 * @package gsxlib
 * @author Filipp Lepalaan <filipp@mcare.fi>
 * @license
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details.
 */

if (TRUE) {
  error_reporting( E_ALL|E_STRICT );
}

$verbs = array( 'create', 'lookup', 'update', 'status', 'label', 'pending', 'details' );
$nouns = array( 'repair', 'part', 'dispatch', 'order', 'return', 'warranty' );

$nouns_str = implode( ', ', $nouns );
$verbs_str = implode( ', ', $verbs );

require 'gsxlib.php';

if( count( $argv ) < 6 ) {
  echo <<<EOT

usage: gsxcl -s sold-to -u username -p password [-r region] [-e environment] [-f format] verb noun
  -s  sold-to     your GSX Sold-To account
  -u  username    the Apple ID with GSX WS API access
  -p  password    the password for the Apple ID
  -r  region      either "am" (America), "emea" (default, Europe, Middle-East, Africa)
                  "apac" (Asia-Pacific) or "la" (Latin America)
  -e  environment the GSX environment. Either empty (production), "it" or "ut"
                  Defaults to production
  -f  format      the output format. Either print_r (default), json, xml or csv
  -d  data        data for the query (serial number, order confirmation, repair number, EEE code, etc
                  Defaults to this machine's serial number
      verb        one of: {$nouns_str}
      noun        one of: {$verbs_str}

EOT;
  exit();
}

$opts = getopt( 's:u:p:r:e:m:q:f:d:' );
list( $verb, $noun ) = array_slice( $argv, -2, 2 );

if( !in_array( $verb, $verbs )) {
	exit( "Error: invalid verb - {$verb}.\n" );
}

if( !in_array( $noun, $nouns )) {
	exit( "Error: invalid noun - {$noun}.\n" );
}

$region = ( isset( $opts['r'] )) ? $opts['r'] : 'emea';
$format = ( isset($opts['f'] )) ? $opts['f'] : 'print_r';
$environment = ( isset( $opts['e'] )) ? $opts['e'] : null;

switch( $noun )
{
	case 'warranty':
		$valid_verbs = array( 'status' );
  	if( !in_array( $verb, $valid_verbs )) {
			printf( "Error: verb should be one of - %s\n", implode( ',', $valid_verbs ));
			exit();
  	}
}

$gsx = GsxLib::getInstance( $opts['s'], $opts['u'], $opts['p'], $environment, $region );

if( !isset( $opts['d'] )) {
  $data = `/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}'`;
 	$data = "serialNumber={$data}";
} else {
  $data = $opts['d'];
  	$data = "serialNumber={$data}";
}

@list( $k, $v ) = explode( '=', $data );
$data = ($k) ? array( $k => $v ) : $data;

switch( $noun ) {
	
  case 'warranty':
  	switch( $verb ) {
  		case 'status':
  			$result = $gsx->warrantyStatus( $data['serialNumber'] );
  			break;
  	}
  	
  break;
  
  case 'part':
    switch( $verb ) {
  		case 'lookup':
  			$result = $gsx->partsLookup( $data );
  			break;
	  	case 'pending':
  		  $result = $gsx->partsPendingReturn( $data );
		    break;
			case 'details':
  		  $result = $gsx->partsPendingReturn( $data );
		    break;
  	}
  	
  break;
  
  case 'repair':
    switch( $verb ) {
  		case 'lookup':
  			$result = $gsx->repairLookup( $data );
  			break;
  		case 'details':
  		  $result = $gsx->partsPendingReturn( $data );
		    break;
		  case 'status':
		    $result = $gsx->repairStatus( $query );
    		break;
  	}
  	
  case 'model':
    $result = $gsx->productModel( $query );
    break;
  case 'osdispatchdetail':
    $result = $gsx->onsiteDispatchDetail( $query );
    break;
  case 'label':
    list($order, $part) = explode( ':', $query );
    $result = $gsx->returnLabel( $order, $part );
    $name = $result->returnLabelFileName;
    echo $result->returnLabelFileData;
    break;
}

switch( $format )
{
  case 'json':
    echo json_encode( $result );
    break;
  
  case 'xml':
  	if( !function_exists( 'simplexml_load_string' )) {
  		exit( "Error: your PHP lacks SimpleXML support!\n" );
  	}
  	
    $xml = simplexml_load_string( '<?xml version="1.0" encoding="utf-8"?><gsxResult />' );
    
    foreach ($result as $k => $v)
    {
      $key = (is_numeric( $k )) ? 'item' : $k;
      $value = (is_object( $v )) ? null : $v;
      $item = $xml->addChild( $key, $value );
      if( is_object( $v )) {
        foreach( $v as $vk => $vv ) {
          $item->addChild( $vk, $vv );
        }
      }
    }
    
    echo $xml->asXML();
    break;
    
  case 'csv':
    $i = 0;
    $fo = fopen('php://stdout', 'w');
    
    foreach( $result as $k => $v )
    {
      if( is_object( $v ))
      {
        $keys = array();
        $vals = array();
        
        foreach ($v as $vk => $vv) {
          if ($i == 0) {
            $keys[] = $vk;
          }
          $vals[] = $vv;
        }
        
        // treat field names of first item as header row
        if ($i == 0) {
          fputcsv( $fo, $keys );
        }
        
        fputcsv( $fo, $vals );
        
      } else {
        $keys[] = $k;
        $vals[] = $v;
      }
      $i++;
    }
    
    if (count($result) === 1) {
      fputcsv($fo, $keys);
      fputcsv($fo, $vals);
    }
    
    fclose($fo);
    break;
  default:
    print_r($result);
    break;
}

?>
