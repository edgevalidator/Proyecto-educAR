<?php 

class Notas_model extends CI_Model{


	function nuevaNota($nota_texto, $fecha_creada){
		$data = array('nota_texto' => $nota_texto, 'nota_fecha_creada' => $fecha_creada);
		$this->db->insert('nota', $data);
	}
	
	function getAll(){
		$q = $this->db->get('nota');

		if($q->num_rows() > 0){
			foreach ($q->result() as $row) {
				$data[] = $row;
			}
			return $data;
		}
	}

	//Retorna las notas con fecha de creación mayor a la pasada por parámetro
	function getLast($dia, $mes, $anio){
		
		$date_string = $anio . "-" . $mes . "-" . $dia;
		$date = new DateTime($date_string);

		$this->db->select('nota_id, nota_texto, nota_fecha_creada');
		$this->db->from('nota');
		
		$q = $this->db->get();

		if($q->num_rows() > 0){
			
			foreach ($q->result() as $row) {
				
				$date_row = new DateTime($row->nota_fecha_creada);
				if ($date_row > $date){
					$data[] = $row;
				}

			}
			return $data;
		}
	}

	function getById($nota_id){
		
		$this->db->select('nota_id, nota_texto, nota_fecha_creada');
		$this->db->from('nota');
		$this->db->where('nota_id =', $nota_id);

		$q = $this->db->get();

		if($q->num_rows() > 0){	
			foreach ($q->result() as $row){
				
				return $row;
			}
		}
	}

	function deleteNota($nota_id){
		$this->db->delete('nota', array('nota_id' => $nota_id));

	}

	function editarNota($nota_id, $nota_texto, $nota_fecha){
		$this->load->database();
		$data = array('nota_texto'=>$nota_texto,
						'nota_fecha_creada'=>$nota_fecha);

		$this->db->where('nota_id',$nota_id);
		$this->db->update('nota',$data);  
	}

}

