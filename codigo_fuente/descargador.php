<!DOCTYPE html>

<html lang="es">

<head>

    <meta charset="UTF-8">

    <title>Descargador V9 Web (Nuclear)</title>

    <style>

        body { 

            font-family: Arial, sans-serif; 

            margin: 50px; 

            background-color: #f4f4f9; 

        }

        .container { 

            background: white; 

            padding: 25px; 

            border-radius: 8px; 

            box-shadow: 0 4px 12px rgba(0,0,0,0.15); 

            max-width: 700px; 

            margin: auto; 

        }

        h2 { 

            color: #2c3e50; 

            border-bottom: 3px solid #3498db; 

            padding-bottom: 10px; 

            margin-bottom: 25px;

            display: flex;

            align-items: center;

        }

        h2 svg { 

            margin-right: 10px; 

        }

        label { 

            display: block; 

            margin-top: 15px; 

            font-weight: bold; 

            color: #333;

        }

        input[type="text"], select { 

            width: 95%; 

            padding: 10px; 

            margin-top: 5px; 

            border: 1px solid #ccc; 

            border-radius: 4px;

            box-sizing: border-box;

        }

        input[type="submit"] { 

            background-color: #27ae60; 

            color: white; 

            padding: 12px 20px; 

            border: none; 

            border-radius: 4px; 

            cursor: pointer; 

            margin-top: 25px;

            font-weight: bold;

            transition: background-color 0.3s;

        }

        input[type="submit"]:hover { 

            background-color: #2ecc71; 

        }

        .result { 

            margin-top: 30px; 

            padding: 20px; 

            background-color: #ecf0f1; 

            border-left: 5px solid #3498db;

            border-radius: 4px; 

            white-space: pre-wrap;

            overflow-x: auto;

        }

        .error {

            border-left: 5px solid #e74c3c;

            background-color: #f7e8e8;

            color: #c0392b;

        }

    </style>

</head>

<body>


<div class="container">

    <h2>

        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="16"></line><line x1="8" y1="12" x2="16" y2="12"></line></svg>

        DESCARGADOR V9 (NUCLEAR)

    </h2>


    <form method="POST" action="">

        <label for="url">Introduce la URL a descargar:</label>

        <input type="text" id="url" name="url" placeholder="Ej: URL de YouTube o Spotify" required>

        

        <label for="opcion">Selecciona una opción:</label>

        <select id="opcion" name="opcion" required>

            <option value="" disabled selected>--- SELECCIONA UNA OPCIÓN ---</option>

            <option value="1">1️⃣ YouTube VÍDEO (MP4) -> Videos</option>

            <option value="2">2️⃣ YouTube AUDIO (MP3) -> Musica</option>

            <option value="3">3️⃣ Spotify (Todo)      -> Spotify</option>

        </select>

        

        <input type="submit" value="Iniciar Descarga">

    </form>


    <?php

    // --- LÓGICA PHP ---

    if ($_SERVER["REQUEST_METHOD"] == "POST" && !empty($_POST['url'])) {

        

        // --- 1. Saneamiento y Variables ---

        $url = escapeshellarg($_POST['url']); 

        $op = $_POST['opcion'];

        

        $output_dir = "";

        $command = "";

        $message = "";


        // DIRECTORIO DE DESCARGAS (Usando la ruta pública acordada)
	$HOME_DIR = "/var/www/html/Descargas/pepe";
        

        // --- 2. Construcción del Comando ---

        switch ($op) {

            case '1': // YouTube Vídeo

                $output_dir = "$HOME_DIR/Descargas_Web/Videos";

                $message = "🎬 Guardando Vídeo MP4 en $output_dir...";

                $command = "yt-dlp --no-playlist -P $output_dir --merge-output-format mp4 $url 2>&1";

                break;

            case '2': // YouTube Audio

                $output_dir = "$HOME_DIR/Descargas_Web/Musica";

                $message = "🎵 Guardando Audio MP3 en $output_dir...";

                $command = "yt-dlp --no-playlist -P $output_dir -x --audio-format mp3 $url 2>&1";

                break;

            case '3': // Spotify

                $output_dir = "$HOME_DIR/Descargas_Web/Spotify";

                $message = "🎧 Guardando Playlist/Canción de Spotify en $output_dir...";

                $command = "~/.local/bin/spotdl $url --output $output_dir 2>&1"; 

                break;

            default:

                echo "<div class='result error'>❌ Error: Opción de descarga no válida.</div>";

                exit; 

        }

        

        // --- 3. Ejecución de la Descarga Local ---


        echo "<div class='result'><h3>$message</h3>";
        
        // 3a. CREAR EL DIRECTORIO SI NO EXISTE (Mejorado)
        if (!file_exists($output_dir)) {
            // 0777 = permisos totales, true = modo recursivo (crea carpetas padre si faltan)
            mkdir($output_dir, 0777, true);
        }
        
        // ASEGURAR PERMISOS ANTES DE DESCARGAR
        // Esto es vital para evitar el error "Permission denied" durante la descarga
        shell_exec("chmod -R 777 " . escapeshellarg($output_dir));
        
        // 3b. Ejecutar la descarga (proceso bloqueante)
        $output = shell_exec($command);
        
        // Volvemos a asegurar permisos para el archivo recién creado
        shell_exec("chmod -R 777 " . escapeshellarg($output_dir));

        $mega_process_started = false;

        // --- 4. Ejecutar el Script de Subida a MEGA en BACKGROUND ---

        // SOLO SI la descarga parece haber sido exitosa

        if ($output !== null && strpos($output, "ERROR:") === false) {

            

            $mega_script_path = "/var/www/ProyectoDescargadorWeb/codigo_fuente/mega.sh"; 

            

            // Ejecución Asíncrona: ¡Permite cerrar la pestaña!

            // 'exec' con nohup, redirección de salida al vacío, y '&' al final.

            exec("nohup sudo $mega_script_path > /dev/null 2>&1 &");

            $mega_process_started = true;

        }



        // --- 5. Mostrar el Resultado al Usuario ---

        echo "<div class='result'>";


        if ($output === null || strpos($output, "ERROR:") !== false) {

            // Error en la descarga

            echo "<span style='color: #c0392b; font-weight: bold;'>❌ DESCARGA FALLIDA:</span> El archivo no se pudo descargar.\n" . htmlspecialchars($output);

        } else {

            // Éxito en la descarga local

            echo "<span style='color: #27ae60; font-weight: bold;'>✅ DESCARGA LOCAL COMPLETADA.</span>\n";

            echo "El archivo se guardó en: {$output_dir}\n\n";

            echo "--- Log de la herramienta de Descarga ---\n" . htmlspecialchars($output);

            

            if ($mega_process_started) {

                // Mensaje clave para el usuario sobre el proceso en segundo plano

                echo "\n\n<span style='color: #3498db; font-weight: bold;'>☁️ SUBIDA A MEGA INICIADA EN SEGUNDO PLANO.</span>\n";

                echo "🎉 **¡Puedes cerrar esta pestaña!** El servidor se encargará de subir el archivo a MEGA (revisa /var/log/mega_upload_bg.log).\n";

            } else {

                echo "\n\n⚠️ La subida a MEGA no se inició debido a un error previo en la descarga.";

            }

        }

        

        echo "</div>";

    }

    ?>

</div>

</body>

</html>
