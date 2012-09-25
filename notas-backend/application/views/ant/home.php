<!DOCTYPE html>
<html>
<head>
	<title>FIRST CI VIEW!!</title>
</head>
<body>
	<h1>PRIMERA VISTA CODEIGNITER!!!</h1>

	
	<?php foreach($row as $r): ?>
		<h1><?php echo $r->nota_id; ?></h1>
		<div><?php echo $r->nota_texto; ?></div>
	<?php endforeach;?>

</body>
</html>