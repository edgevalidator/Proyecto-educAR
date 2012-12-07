<?php 

class Nota extends CI_Controller {

	function index(){	
		$this->load->helper('url');
		$this->load->model('notas_model');
		$data['notas'] = $this->notas_model->getAll();
		$this->load->view('form', $data);
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

		$this->_generateDfusionProject();
		
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
			$this->_generateDfusionProject();		
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
		//$this->_armarNota($nota_texto);
	}

	function borrarNota($id_nota){
		$this->load->helper('url');
		$this->load->model('notas_model');
		$this->notas_model->eliminarNota($id_nota);
		$this->_generateDfusionProject();
		redirect(site_url());
	}

	function armarNota($texto_nota, $nota_file){
		
		$nota = "imagenes/nota.png";
		//$rImg = imagecreatefromjpeg($nota);
		$rImg = imagecreatefrompng($nota);

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

		imagepng($rImg, $nota_file);
	}



	//Private functions
	
	function _largoPalabra($palabra){

		$fuente = 'imagenes/saxmono.ttf';
		$dims = imagettfbbox(10, 0, $fuente, $palabra);
		$width = $dims[4] - $dims[6]; 

		return $width;
	}

	//Genera el proyecto entero de DFusion
	function _generateDfusionProject(){
	
		$this->_prepareDfusionDirs();
		$lua_changed_ok = $this->_editDfusionLua();
		$dpd_changed_ok = $this->_editDfusionDPD();
		
		if($lua_changed_ok && $dpd_changed_ok){
			$this->_generateDfusionKey();	
		}

	}

	//Elimina el directorio generado y crea uno nuevo a partir del template
	function _prepareDfusionDirs(){
		$dfusion_dir_source = 'template_dfusion';
		$dfusion_dir_dest   = 'generated_dfusion_project';
		$this->_rrmdir($dfusion_dir_dest);
		$this->_recurse_copy($dfusion_dir_source, $dfusion_dir_dest);
	}

	//Copia un directorio recursivamente
	function _recurse_copy($src,$dst) { 
	    $dir = opendir($src); 
	    @mkdir($dst); 
	    while(false !== ( $file = readdir($dir)) ) { 
	        if (( $file != '.' ) && ( $file != '..' )) { 
	            if ( is_dir($src . '/' . $file) ) { 
	                $this->_recurse_copy($src . '/' . $file,$dst . '/' . $file); 
	            } 
	            else { 
	                copy($src . '/' . $file,$dst . '/' . $file); 
	            } 
	        } 
	    } 
	    closedir($dir); 
	} 

	//Elimina un directorio recursivamente
	function _rrmdir($dir) {
	    foreach(glob($dir . '/*') as $file) {
	        if(is_dir($file))
	            $this->_rrmdir($file);
	        else
	            unlink($file);
	    }
	    rmdir($dir);
	}

	//Agrega los datos al DPD
	function _editDfusionDPD(){
		
		$dpd_filename = "generated_dfusion_project/Giroscopo.dpd";
		$dpd_rename_filename = "generated_dfusion_project/Giroscopo.xml";
		$all_notes = $this->notas_model->getAll();

		if(rename($dpd_filename, $dpd_rename_filename)){
			
			$notes_index = 1;			
			$xml = new DOMDocument();
			$xml->load($dpd_rename_filename);
			$xml->formatOutput = true;

			foreach ($all_notes as $note){

				$note_file_name = "nota_" . $notes_index . ".png";
				$notes_files_url = "generated_dfusion_project/notas/nota/";

				$this->armarNota($note->nota_texto, $notes_files_url . $note_file_name);

				$userFileFiltersTag = $xml->getElementsByTagName("userfilefilters")->item(0);

				$file_node = $xml->createElement("file");
				
				$relative_path_attribute = $xml->createAttribute("relativePath");
				$relative_path_attribute->value = "notas/nota/nota_" . $notes_index . ".png";

			
				$file_node->appendChild($relative_path_attribute);

				$userFileFiltersTag->appendChild($file_node);
				
				//Files Tag
				$filesTag = $xml->getElementsByTagName("files")->item(0);
				$new_file_node  = $xml->createElement("file");
				$file_relative_path_attribute = $xml->createAttribute("relativePath");
				$file_relative_path_attribute->value = ".\\notas\\nota\\nota_" . $notes_index . ".png";

				$new_file_node->appendChild($file_relative_path_attribute);

				$new_file_config_node = $xml->createElement("configuration");
				$new_file_config_name_attr = $xml->createAttribute("name");
				$new_file_config_name_attr->value="@Home|All Platforms";
				$new_file_exclude_build_attr = $xml->createAttribute("excludeFromBuild");
				$new_file_exclude_build_attr->value="true";

				$new_file_config_node->appendChild($new_file_config_name_attr);
				$new_file_config_node->appendChild($new_file_exclude_build_attr);
				
				$new_file_config_node_2 = $xml->createElement("configuration");
				$new_file_config_name_attr_2 = $xml->createAttribute("name");
				$new_file_config_name_attr_2->value="@Home|windows";
				$new_file_exclude_build_attr_2 = $xml->createAttribute("excludeFromBuild");
				$new_file_exclude_build_attr_2->value="true";

				$new_file_config_node_2->appendChild($new_file_config_name_attr_2);
				$new_file_config_node_2->appendChild($new_file_exclude_build_attr_2);

				$new_file_config_node_3 = $xml->createElement("configuration");
				$new_file_config_name_attr_3 = $xml->createAttribute("name");
				$new_file_config_name_attr_3->value="mobile|All Platforms";
				$new_file_exclude_build_attr_3 = $xml->createAttribute("excludeFromBuild");
				$new_file_exclude_build_attr_3->value="true";

				$new_file_config_node_3->appendChild($new_file_config_name_attr_3);
				$new_file_config_node_3->appendChild($new_file_exclude_build_attr_3);

				$new_file_node->appendChild($new_file_config_node);
				$new_file_node->appendChild($new_file_config_node_2);
				$new_file_node->appendChild($new_file_config_node_3);

				$filesTag->appendChild($new_file_node);

				$notes_index += 1;
			}

			$xml->save($dpd_rename_filename);

			return rename($dpd_rename_filename, $dpd_filename);
		}
	}

	//Edita archivo giroscopo.lua. Cada vez que se agrega una nota se suma 1 a la cantidad total.
	function _editDfusionLua(){

		$lua_filename = "generated_dfusion_project/giroscopo.lua";
	
		$lua_new_line = "Notas = { length = #, current = 1 }";

		$notes_count = $this->notas_model->notesCount();

		$str_notes_count = mysql_real_escape_string($notes_count);

		$lua_new_line_replace = str_replace("#", $str_notes_count, $lua_new_line);
		
		$lua_file = file($lua_filename);
		
		if($lua_file){
			
			$encontre = false;

			foreach ($lua_file as &$line) {
 			   if (preg_match("/Notas = { length =/", $line)){
 			   		$line = $lua_new_line_replace;
 			   		$encontre = true;
 			   }else{
 			   }
			}

			if($encontre){
				$lua_file_to_write = fopen($lua_filename, 'w');
				$bytes_written     = fwrite($lua_file_to_write, implode("\n", $lua_file));
				$fclose_ok         =fclose($lua_file_to_write);	

				return $bytes_written > 0 && $fclose_ok;
			}
	
		}

		return false;
	}

	//Ejecuta el EXE tiProtectorAR2Free
	function _generateDfusionKey(){
		exec('tiProtectorAR2Free.exe ./generated_dfusion_project/Giroscopo.dpd ./generated_dfusion_project/ -t mobile -p android');
	}

}