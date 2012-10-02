<html>	
<head>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
	<script type="text/javascript" src="js/flexigrid.js"></script>
	<link rel="stylesheet" type="text/css" href="css/flexigrid.css">
	<script type="text/javascript" src="js/jquery.fancybox.js?v=2.1.0"></script>
	<link rel="stylesheet" type="text/css" href="css/jquery.fancybox.css?v=2.1.0" media="screen" />
	<link rel="stylesheet" type="text/css" href="css/view.css" media="all">
</head>
<body id="main_body">
	<img id="top" src='<?php echo base_url()."imagenes/top.png"?>' alt="">
	<div id="form_container">
		<h1><a>Notificación de eventos</a></h1>
		<form id="form_377654" class="appnitro" enctype="multipart/form-data" method="get" action="success.html">
					
			<div class="form_description">
			<h2>Notas</h2>
			</div>	
		<div id="contTabla">
			<table class="tabla_notas">
				<thead>
		     		<tr>
				  		<th width="60">ID</th>
				  		<th width="300">Texto</th>
				  		<th width="180">Ultima fecha modificacion</th>
		     		</tr>	
				</thead>
				<tbody>
				    
				    <?php foreach($notas as $nota): ?>
				 		<tr>
				 			<td><?php echo $nota->nota_id; ?>           </td>
				 			<td><?php echo $nota->nota_texto; ?>        </td>
				 			<td><?php echo $nota->nota_fecha_creada; ?> </td>
				 		</tr>
				 	<?php endforeach; ?>

				</tbody>
			</table>
		</div>
		</form>
	</div>
	<img id="bottom" src='<?php echo base_url()."imagenes/bottom.png"?>' alt="">

	
	<script type="text/javascript">
		
		$(document).ready(function() {
			
			$('.tabla_notas').flexigrid({
				buttons:[
					{name: 'Add', bclass: 'fancybox', onpress: addNota},
					{name: 'Editar', bclass: 'edit', onpress : editNota},
					{name: 'Delete', bclass: 'fancybox', onpress : deleteNota},
				],
				usepager: true,
				dataType: 'json',
				title: 'Notas',
				useRp: true,
				rp: 15,
				showTableToggleBtn: true,
				width: 600,
				singleSelect: true,
				height: 200
			});

		});

		
		function addNota(){
			var baseurl = "<?php echo site_url('nota/nueva') ?>";
			window.location.href = baseurl;
		}

		function editNota(){
			var row = getSelectedRow();
			if (row == ""){
				alert("Debe seleccionar un registro");
			}else{
				var row_str   = row.toString();
				var split_row = row_str.split(",");
					
				var id_nota   = split_row[0];

				var baseurl = "<?php echo site_url('nota/editarNota'); ?>" + "/" + id_nota;
				window.location.href = baseurl;
			}
		}

		function deleteNota(){
			
			var row = getSelectedRow();
			if (row == ""){
				alert("Debe seleccionar un registro", "Atención");
			}else{
				if (confirm("¿Desea eliminar el registro seleccionado?", "Confirmación")) { 
					var row_str   = row.toString();
					var split_row = row_str.split(",");
					
					var id_nota   = split_row[0];

					var baseurl = "<?php echo site_url('nota/borrarNota'); ?>" + "/" + id_nota;
					window.location.href = baseurl;
					

				}
			}
		}

		function getSelectedRow() { 
			var arrReturn   = []; 
		    $('.trSelected').each(function() { 
		            var arrRow              = []; 
		            $(this).find('div').each(function() { 
		                    arrRow.push( $(this).html() ); 
		            }); 
		            arrReturn.push(arrRow); 
		    }); 
		    return arrReturn; 
		}	
	
	</script>
</body>
</html>