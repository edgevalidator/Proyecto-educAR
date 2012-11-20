package com.educar.giroscopo;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.json.JSONArray;
import org.json.JSONObject;

import ti.dfusionmobile.tiComponent;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.educar.giroscopo.notas.constants.NotasConstants;
import com.educar.giroscopo.notas.handlers.NotasHandler;
import com.educar.giroscopo.notas.handlers.SharedPreferencesHandler;
import com.educar.giroscopo.utils.HttpUtil;

public class EducARActivity extends Activity {
    
	private FrameLayout _frameLayout;
	private tiComponent _tiComponent; 
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        _tiComponent = new tiComponent(this);
    }
    
    @Override
    public void onStart() {
	    _frameLayout = new FrameLayout(this);
	    _frameLayout.setKeepScreenOn(true);
	    
	    _tiComponent.initialize(_frameLayout);
	    _tiComponent.activateAutoFocusOnDownEvent(true);
	    
	    setContentView(_frameLayout);
	    
	    super.onStart();
	    
	    UnzipProjectTask task = new UnzipProjectTask();
	    task.execute();
	    
	    /*
	    _linearLayout = new LinearLayout(this);
    	_linearLayout.setBackgroundColor(Color.YELLOW);
    	
	    _frameLayout = new FrameLayout(this);
	    _frameLayout.setKeepScreenOn(true);
	    _frameLayout.setBackgroundColor(Color.GREEN);
	    
	    int width = getWindowManager().getDefaultDisplay().getWidth();
	    int height = width * (3/4);
	    
	    LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(width, height);
	    params.gravity = Gravity.CENTER;
	    
	    _linearLayout.addView(_frameLayout, params);
	    
	    setContentView(_linearLayout);
	    
	    super.onStart();
	    */
    }
    
    @Override
    public void onResume(){
	    super.onResume();
	    _tiComponent.onResume();
	    _tiComponent.playScenario();
    }
    
    @Override
    public void onPause() {
		super.onPause();
	    _tiComponent.pauseScenario();
	    _tiComponent.onPause();
    }
    
    @Override
    public void onStop() {
	    super.onStop();
	    _tiComponent.terminate();
    }
    
    @Override
    public void onDestroy() {
	    super.onDestroy();
	    _frameLayout = null;
	    _tiComponent = null;
    }
    
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		String [] params = {};
		switch (item.getItemId()) {
			case R.id.boton_01:
				_tiComponent.enqueueCommand("boton_01", params);
				return true;
			case R.id.boton_02:
				_tiComponent.enqueueCommand("boton_02",params);
				return true;
			case R.id.boton_04:
				_tiComponent.enqueueCommand("boton_04", params);
				return true;
			case R.id.boton_notas:
				_tiComponent.enqueueCommand("boton_notas",params);
				return true;
			case R.id.boton_vectores:
				_tiComponent.enqueueCommand("boton_vectores", params);
				return true;
			case R.id.boton_animaciones:
				_tiComponent.enqueueCommand("boton_animaciones",params);
				return true;
			case R.id.boton_direccion:
				_tiComponent.enqueueCommand("boton_direccion", params);
				return true;
			case R.id.boton_precesion:
				_tiComponent.enqueueCommand("boton_precesion", params);
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}
	
	private String getZipFilename(){
		return "content.zip";
	}
	
	private File getUnzipDir(){
		return getDir("www", Context.MODE_PRIVATE);
	}
	
	private File getProjectFile(){
		return new File(getUnzipDir(), "Giroscopo.dpd");
	}
	
	class UnzipProjectTask extends AsyncTask<Void, Void, Void> {
		
		private ProgressDialog dialog = null;
		private boolean error = false;
		
		public UnzipProjectTask(){
			dialog = new ProgressDialog(EducARActivity.this);
		}
		
		@Override
		protected void onPreExecute(){
			dialog.setMessage("Loading...");
	        dialog.show();
		}
		
		@Override
		protected Void doInBackground(Void... params) {
			
			File projectFile = getProjectFile();
			
			if(!projectFile.exists()){
				
				File dir = getUnzipDir();
				InputStream in = null;
				try {
					in = getAssets().open(getZipFilename(), Context.MODE_PRIVATE);
					
					ZipInputStream zis = null;
					try {
						zis = new ZipInputStream(new BufferedInputStream(in));
						
						ZipEntry ze;
						while ((ze = zis.getNextEntry()) != null) {
							if(ze.isDirectory()){
								File file = new File(dir, ze.getName());
								file.mkdirs();
							} else {
								File file = new File(dir, ze.getName());
								
								OutputStream out = null;
								try {
									out = new BufferedOutputStream(new FileOutputStream(file), 1024);
									byte[] buffer = new byte[1024];
									int count;
									while ((count = zis.read(buffer)) != -1) {
										out.write(buffer, 0, count);
									}
								} catch (IOException e){
									Log.d("EducARActivity", e.getMessage());
									error = true;
								} finally {
									if(out != null){
										try {
											out.flush();
											out.close();
										} catch (IOException e){ }
									}
								}
							}
						}
					} catch (IOException e){
						Log.d("EducARActivity", e.getMessage());
						error = true;
					} finally {
						if(zis != null){
							try {
								zis.close();
							} catch (IOException e) { }
						}
					}
				} catch (IOException e) {
					Log.d("EducARActivity", e.getMessage());
					error = true;
				} finally {
					if(in != null){
						try {
							in.close();
						} catch (IOException e){ }
					}
				}
			}
			
			/*
			if(!error){
		
				Date ultimaNota = new Date(Long.MIN_VALUE);

				SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
				boolean ultimaNotaCambio = false;

				Calendar c = Calendar.getInstance();

				SharedPreferencesHandler preferences = new SharedPreferencesHandler(EducARActivity.this);
				String ultimaFechaNota = preferences.getValue(NotasConstants.ULTIMA_NOTA_BAJADA);

				try {
					int year     = 1;
					int month    = 1;
					int day      = 1;
					int hora     = 1;
					int minutos  = 1;
					int segundos = 1;

					if (ultimaFechaNota != null && ultimaFechaNota != "") {
						c.setTime(df.parse(ultimaFechaNota));

						year     = c.get(Calendar.YEAR);
						month    = c.get(Calendar.MONTH) + 1;
						day      = c.get(Calendar.DAY_OF_MONTH);
						hora     = c.get(Calendar.HOUR);
						minutos  = c.get(Calendar.MINUTE);
						segundos = c.get(Calendar.SECOND);
					}

					String fechaParam = year + "/" + month + "/" + day + "/" + hora + "/" + minutos + "/" + segundos;
					
					Log.i("FECHA_PARAM", fechaParam);
					
					JSONArray ultimasNotas = HttpUtil.getRequest(NotasConstants.ULTIMAS_NOTAS_URL+ fechaParam);
					
					
					if (ultimasNotas != null) {

						for (int i = 0; i < ultimasNotas.length(); i++) {

							JSONObject obj = ultimasNotas.getJSONObject(i);
							int notaId            = obj.getInt("nota_id");
							String fechaNota      = obj.getString("nota_fecha_creada");
							int notaEliminada = obj.getInt("nota_eliminada");
							
							String fileName = "nota_" + notaId + ".png";
							
							Log.i("NOTA_", "Nota => " + fileName);
							
							//Busco si tengo la nota que se elimino para borrarla
							if(notaEliminada == 1){
								notasHandler.deleteNota(fileName);
							}else{
								Date fechaNotaBajada = df.parse(fechaNota);

								if (fechaNotaBajada.after(ultimaNota)) {
									ultimaNota = fechaNotaBajada;
									ultimaNotaCambio = true;
								}

								String downloadUrl = NotasConstants.GET_NOTA_URL + notaId;

								Log.i("D_URL", downloadUrl);

								notasHandler.downloadNotaFromURL(downloadUrl, fileName);
							}
						}
						
						if (ultimaNotaCambio) {
							String sUltimaNota = df.format(ultimaNota).toString();
							preferences.setValue(NotasConstants.ULTIMA_NOTA_BAJADA, sUltimaNota);
							Log.i("NOTA_CAMBIO", "CAMBIONOTA => " + sUltimaNota);
						}

					} else {
						Toast.makeText(EducARActivity.this,"No hay nuevas notas para descargar", Toast.LENGTH_LONG).show();
					}
				} catch (Exception e) {
					Log.e("Exception", e.getMessage());
				}
				
			}
			*/
			return null;
		}

		@Override
		protected void onPostExecute(Void result) {
			Log.d("EducARActivity", "ended");
			
			if (dialog.isShowing()) {
				Log.d("EducARActivity", "dismissing");
	            dialog.dismiss();
	        }
			
			if(error){
				AlertDialog.Builder builder = new AlertDialog.Builder(EducARActivity.this);
				builder.setMessage(R.string.alert_unzip_error)
				       .setCancelable(false)
				       .setNeutralButton(R.string.alert_unzip_error_exit, new DialogInterface.OnClickListener() {
				           public void onClick(DialogInterface dialog, int id) {
				                EducARActivity.this.finish();
				           }
				       });
				builder.create().show();
			} else {
				_tiComponent.loadScenario(getProjectFile().getPath());
	    	    _tiComponent.playScenario();
			}
		}
	}
}