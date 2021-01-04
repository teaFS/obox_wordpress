<?php 

$TOKEN_LEN = 4 * 6; // 24 characters length

function gen_token() {
    global $TOKEN_LEN;
    // base 36: lets get 4 random base 36 signs
    // $MAX_RAND is '1679615', should be well 
    // bellow getrandmax() value
    $MAX_RAND = (1 + 36 + 36*36 + 36*36*36) * 35;
    $token = '';
    
    // base 36: 10 + 26 - 1 => 35
    for( $i = $TOKEN_LEN; $i > 0; --$i ) {
    
        if( $i % 4 === 0 ) {
            $e4 = rand(0, $MAX_RAND);
        }
        
        $e = $e4 % 36;
        $e4 = (int)($e4 / 36);
        
        $token .= ($e < 10) ? chr(48 + $e) : chr(87 + $e);
    }
    
    return $token;
}

$token_file='/tmp/secret_token.txt';
$token = '';

if( file_exists($token_file) ) {
    $fh = fopen($token_file, 'r') or die("Unable to open token file");
    
    $token = fread($fh, $TOKEN_LEN);
} else {
    // create file
    $fh = fopen($token_file, 'w') or die("Unable to create token file");
    
    fwrite($fh, ($token = gen_token()) . PHP_EOL);
}

fclose($fh);

if( is_int($argc) ) {
    // call from shell
    echo "Click bellow to login: " . PHP_EOL . 
         "http://localhost:" . getenv('HTTP_EXP_PORT') . "/" . $argv[0] . "?" . $token . PHP_EOL;
}

?>
