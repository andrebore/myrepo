<?php
require 'vendor/autoload.php';
use Guzzle\Http\Client;

$client = new GuzzleHttp\Client();
$res = $client->request('GET', 'http://itlabvbr01.veeamita.local:9399/web');
echo $res->getStatusCode();

echo $res->getHeader('content-type');

echo $res->getBody();


?>