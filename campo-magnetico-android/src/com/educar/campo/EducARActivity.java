package com.educar.campo;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.http.util.ByteArrayBuffer;
import org.json.JSONArray;

import ti.dfusionmobile.tiComponent;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.FrameLayout;

import com.educar.campo.notas.constants.NotasConstants;
import com.educar.campo.utils.HttpUtil;

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
			case R.id.boton_vectores:
				_tiComponent.enqueueCommand("boton_lineas", params);
				return true;
			case R.id.boton_ecuaciones:
				_tiComponent.enqueueCommand("boton_ecuaciones", params);
				return true;
			default:
				return super.onOptionsItemSelected(item);
		}
	}
	
	private File getDownloadDir(){
		return getDir("tmp", Context.MODE_PRIVATE);
	}
	
	private String getZipFilename(){
		return "dfusion.zip";
	}
	
	private File getUnzipDir(){
		return getDir("www", Context.MODE_PRIVATE);
	}
	  
	private String getProjectFilename(){
		return "Campo.dpd";
	}
	
	private DateFormat getDateFormat(){
		return new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
	}
	
	private SharedPreferences getSharedPreferences(){
		return this.getSharedPreferences("", Activity.MODE_PRIVATE);
	}
	
	class UnzipProjectTask extends AsyncTask<Void, Void, Void> {
		
		private ProgressDialog dialog = null;
		private boolean error = false;
		
		public UnzipProjectTask(){
			dialog = new ProgressDialog(EducARActivity.this);
		}
		
		@Override
		protected void onPreExecute(){
			dialog.setMessage("Descargando contenido...");
	        dialog.show();
		}
		
		@Override
		protected Void doInBackground(Void... params) {
			File projectFile = new File(getUnzipDir(), getProjectFilename());
			
			Date date = new Date();
			if(!projectFile.exists() || shouldDownloadProject(date)){
				InputStream in = null;
				try {
					in = getAssets().open(getZipFilename(), Context.MODE_PRIVATE);
					File file = new File(getDownloadDir(), getZipFilename());  
					//in = downloadProject(file, date);
					
					Log.d("EducARActivity", "Emptying " + getUnzipDir().getPath());
					emptyDirectory(getUnzipDir());
					
					Log.d("EducARActivity", "Extracting " + file.getPath());
					extractZip(in);
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
			
			return null;
		}
		
		private boolean shouldDownloadProject(Date date){
			String lastDownloaded = getSharedPreferences().getString(NotasConstants.ULTIMA_NOTA_BAJADA, "never");
			Log.d("EducARActivity", "Project last downloaded on " + lastDownloaded);
			
			if(lastDownloaded.equals("never")){
				return false;
			} else {
				String url = NotasConstants.PROJECT_LAST_MODIFIED;
				Log.d("EducARActivity", "Downloading JSON from " + url);
				
				JSONArray json = HttpUtil.getRequest(url);
				try {
					String lastModified = json.getJSONObject(0).getString("last_modified_date");
					Log.d("EducARActivity", "Project last modified on " + lastModified);
					
					Date dateLastModified = getDateFormat().parse(lastModified);
					Date dateLastDownloaded = getDateFormat().parse(lastDownloaded);
					
					if(dateLastModified.after(dateLastDownloaded)){	
						date.setTime(dateLastModified.getTime());
						return true;
					} else {
						return false;
					}
				} catch(Exception e) {
					return false;
				}
			}
		}
		
		public InputStream downloadProject(File dir, Date date) throws IOException {
			URL url = new URL(NotasConstants.DOWNLOAD_ZIPED_PROJECT);
			Log.e("EducARActivity", "Downloading zip from " + url.toString());
			
			URLConnection ucon = url.openConnection();
			InputStream is = ucon.getInputStream();
			BufferedInputStream bis = new BufferedInputStream(is);
			ByteArrayBuffer baf = new ByteArrayBuffer(5000);
			int current = 0;
			while ((current = bis.read()) != -1) {
				baf.append((byte) current);
			}
			
			File file = new File(dir, "dfusion.zip");
			Log.e("EducARActivity", "Writing downloaded zip to " + file.getAbsolutePath());
			
			FileOutputStream fos = new FileOutputStream(file); 
			fos.write(baf.toByteArray());
			fos.flush();
			fos.close();
			
			String dateString = getDateFormat().format(date);			
			Log.e("EducARActivity", "Setting lastDownload key to " + dateString);
			
			getSharedPreferences().edit().putString(NotasConstants.ULTIMA_NOTA_BAJADA, dateString).commit();
			
			return new FileInputStream(file);
		}
		
		private void emptyDirectory(File dir){
			String[] children = dir.list();
	        for (int i = 0; i < children.length; i++) {
	            File file = new File(dir, children[i]);
	            boolean success = file.delete();
	            if(success){
	            	Log.d("EducARActivity", "Deleted " + file.getPath());
	            } else {
	            	Log.d("EducARActivity", "Couldn't delete " + file.getPath());
	            }
	        }
		}

		private void extractZip(InputStream in){
			ZipInputStream zis = null;
			try {
				zis = new ZipInputStream(new BufferedInputStream(in));
				
				ZipEntry ze;
				while ((ze = zis.getNextEntry()) != null) {
					if(ze.isDirectory()){
						File file = new File(getUnzipDir(), ze.getName());
						file.mkdirs();
					} else {
						File file = new File(getUnzipDir(), ze.getName());
						
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
				File file = new File(getUnzipDir(), getProjectFilename());
				_tiComponent.loadScenario(file.getPath());
	    	    _tiComponent.playScenario();
			}
		}
	}
}