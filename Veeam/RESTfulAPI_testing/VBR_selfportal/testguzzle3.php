<?php
require 'vendor/autoload.php';
use Guzzle\Http\Client;
//use GuzzleHttp\Client;
use GuzzleHttp\Psr7;
use GuzzleHttp\RequestOptions;
use GuzzleHttp\Exception\RequestException;

$client = new GuzzleHttp\Client();
$res = $client->request('GET', 'http://itlabvbr01.veeamita.local:9399/api/');
$res2 = $client->request('POST', 'http://itlabvbr01.veeamita.local:9399/api/SessionMngr/?v=latest',[
'headers' => [
    'Authorization'     => 'Basic YW5kcmVhOlNlNG1AJHQzcjMwMA=='
	]
	]);

$session_id = (string) $res2->getHeaderLine('x-restsvcsessionid');


$backupserver = $client->request('GET', 'http://itlabvbr01.veeamita.local:9399/api/backupServers',[
'headers' => [
	'X-RestSvcSessionId'	=> $session_id
]
]);

echo $backupserver->getStatusCode();
//echo $backupserver->getBody();
$content = $backupserver->getBody()->getContents();
echo $content;

$res3 = $client->request('DELETE', 'http://itlabvbr01.veeamita.local:9399/api/logonSessions/' . base64_decode($session_id),[
'headers' => [
	'X-RestSvcSessionId'	=> $session_id
]
]);

echo $res3->getStatusCode();
echo $res3->getBody();


?>