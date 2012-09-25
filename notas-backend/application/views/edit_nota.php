<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Editar nota</title>
	<link rel="stylesheet" type="text/css" href='<?php echo base_url()."css/view.css"?>' media="all">
	<script type="text/javascript" src='<?php echo base_url()."js/view.js"?>'></script>
</head>

<body id="main_body" >
	
	<img id="top" src='<?php echo base_url()."imagenes/top.png"?>' alt="">

	<div id="form_container">
	
		<h1><a>Editar nota</a></h1>
		
		<form id="new_nota_form" class="appnitro"  method="post" action="http://localhost/notas-backend/index.php/nota/editar">
			
			<div class="form_description">
			<h2>Editar nota</h2>
			</div>						
				<ul >
					<li id="li_1" >
						<label class="description" for="element_1">Nota </label>
						<div>
							<textarea id="texto_nota" name="nota_texto" class="element textarea medium"><?php echo $nota->nota_texto; ?></textarea> 
						</div> 
					</li>		
					<li id="li_2" >
						<label class="description" for="element_2">Ejercicio </label>
						<div>
							<select class="element select medium" id="element_2" name="element_2"> 
								<option value="1"  selected="selected" >Giroscopo</option>
							</select>
						</div> 
					</li>
					<li class="buttons">
						<input type="hidden" id="nota_id" name="nota_id" value="<?php echo $nota->nota_id; ?>" />
						<input id="saveForm" class="button_text" type="submit" name="submit" value="Guardar" />
						<input type="button" id="btn_cancelar" value="Cancelar" onClick="cancelar();" />
					</li>
				</ul>
		</form>	
	</div>
	<img id="bottom" src='<?php echo base_url()."imagenes/bottom.png"?>' alt="">

	<script type="text/javascript">
		
		function cancelar(){
			var cancelUrl = "<?php echo site_url();?>";
			window.location.href = cancelUrl;
		}

	</script>

</body>

</html>