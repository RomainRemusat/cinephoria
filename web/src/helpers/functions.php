<?php
function afficheSession() {
echo"<pre>";print_r($_SESSION);echo"</pre>";
}

function affichePost() {
echo"<pre>";print_r($_POST);echo"</pre>";
}

function affiche($var) {
    echo"<pre>";print_r($var);echo"</pre>";
}
function afficheFiles() {
echo"<pre>";print_r($_FILES);echo"</pre>";
}

function afficheGet() {
echo"<pre>";print_r($_GET);echo"</pre>";
}

function afficheServer() {
echo"<pre>";print_r($_SERVER);echo"</pre>";
}
?>