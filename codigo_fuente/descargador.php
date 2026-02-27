<?php
if ($_SERVER["REQUEST_METHOD"] == "POST" && !empty($_POST['url'])) {
    $url = escapeshellarg($_POST['url']);
    $dir = "/var/www/html/Descargas";
    shell_exec("mkdir -p $dir && chmod 777 $dir");
    
    // Descarga
    shell_exec("yt-dlp -P $dir -x --audio-format mp3 $url 2>&1");
    
    // Subida lanzada como wolf
    shell_exec("sudo -u wolf /var/www/DescargadorWeb/codigo_fuente/mega_final.sh > /dev/null 2>&1 &");
    echo "<h1> ^=^z^` PROCESO INICIADO</h1>";
}
?>
<form method="POST"><input type="text" name="url" style="width:80%"><input type="submit" value="SUBIR"></form>
