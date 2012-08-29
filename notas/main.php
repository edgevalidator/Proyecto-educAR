<?php

$texto_nota = $_GET['texto'];
$color_nota = $_GET['color'];

$nota = "nota_" . $color_nota . ".jpg";
$rImg = ImageCreateFromJPEG($nota);

$color = imagecolorallocate($rImg, 0, 0, 0);		

$fuente = './Fuentes/saxmono.ttf';

$dims = imagettfbbox(10, 0, $fuente, $texto_nota);

$width = $dims[4] - $dims[6];

//Redondeo para arriba
$cant_lineas = ceil($width / 286);

//Cada elemento de este array representa una línea de texto a mostrar en la nota
$division_palabras = [];

$lista_palabras = [];

$ultima_palabra = "";


//Divido el texto en varias líneas para que entre en la nota.
while($cant_lineas > 0){

	$largo = largoPalabra($texto_nota);
	$primeras_palabras = "";
	
	if ($largo > 286){

		$lista_palabras  = [];
		while ($largo > 286){
			
			$palabras = explode(" ",$texto_nota);
			$ultima_palabra = $palabras[count($palabras)-1];
			
			//Saco la última posición del array
			unset($palabras[count($palabras)-1]);

			$primeras_palabras = implode(" ", $palabras);
			
			$largo = largoPalabra($primeras_palabras);

			array_unshift($lista_palabras, $ultima_palabra);

			$texto_nota = $primeras_palabras;

		}

		$division_palabras[] = $primeras_palabras;

		$texto_nota = implode(" ", $lista_palabras);

		$cant_lineas = $cant_lineas -1;

	}else{
		
		$division_palabras[] = $texto_nota;	
		$cant_lineas = $cant_lineas - 1;	
	}
	
}

//Recorro array de líneas y las dibujo sobre la nota.
$y = 12;
foreach ($division_palabras as $linea){
	imagettftext ($rImg , 10 , 0 , 2 , $y , $color, $fuente, $linea);
	$y = $y + 11;	
}

header('Content-type: image/jpeg');
header('Content-Disposition: attachment; filename="' . $nota . '"');
imagejpeg($rImg);
readfile($rImg);



function largoPalabra($palabra){
	
	$fuente = './Fuentes/saxmono.ttf';
	$dims = imagettfbbox(10, 0, $fuente, $palabra);
	$width = $dims[4] - $dims[6]; 

	return $width;
}

?>


