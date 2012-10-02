<?php 


class Nota extends CI_Controller {

	function index(){	
		$this->load->helper('url');
		$this->load->model('notas_model');
		$data['notas'] = $this->notas_model->getAll();
		$this->load->view('list_notas', $data);
	}
	
	function nueva(){
		$this->load->helper('url');
		$this->load->view('form');
	}

	function nuevaNota(){
		$this->load->helper('url');
		$texto = $_POST['texto_nota'];
		$fecha = $now = date("Y-m-d H:i:s");
		$this->load->model('notas_model');
		$this->notas_model->nuevaNota($texto, $fecha);
		redirect(site_url());
	}

	function editarNota($id_nota){
		$this->load->helper('url');
		$this->load->model('notas_model');
		$data['nota'] = $this->notas_model->getById($id_nota);
		$this->load->view('edit_nota', $data);
	}

	function editar(){
		$this->load->helper('url');
		$this->load->model('notas_model');
		
		$nota_id    = $_POST['nota_id'];
		$nota_texto = $_POST['nota_texto'];

		$nota = $this->notas_model->getById($nota_id);

		if($nota->nota_texto != $nota_texto){
			$fecha = $now = date("Y-m-d H:i:s");
			$this->notas_model->editarNota($nota_id, $nota_texto, $fecha);		
		}
		redirect(site_url());	
	}

	function ultimasNotas($dia, $mes, $anio, $hora, $minuto, $segundo){
		$this->output->set_header('Content-Type: application/json; charset=utf-8');
		$this->load->model('notas_model');
		$data = $this->notas_model->getLast($dia, $mes, $anio, $hora, $minuto, $segundo);
		echo json_encode($data);
	}

	function getNota($id_nota){	
		$this->load->model('notas_model');
		$nota = $this->notas_model->getById($id_nota);
		
		$nota_texto = $nota->nota_texto;
		$this->_armarNota($nota_texto);
	}

	function borrarNota($id_nota){
		$this->load->helper('url');
		$this->load->model('notas_model');
		$this->notas_model->eliminarNota($id_nota);
		redirect(site_url());
	}

	function _armarNota($texto_nota){
		
		$nota = "imagenes/nota.jpg";
		$rImg = imagecreatefromjpeg($nota);

		$color = imagecolorallocate($rImg, 0, 0, 0);		

		$fuente = 'imagenes/saxmono.ttf';

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

			$largo = $this->_largoPalabra($texto_nota);
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

	}


	function _largoPalabra($palabra){
		
		$fuente = 'imagenes/saxmono.ttf';
		$dims = imagettfbbox(10, 0, $fuente, $palabra);
		$width = $dims[4] - $dims[6]; 

		return $width;
	}

}