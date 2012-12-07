package com.educar.giroscopo.notas.handlers;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import org.apache.http.util.ByteArrayBuffer;

import com.educar.giroscopo.notas.constants.NotasConstants;

import android.content.Context;
import android.content.ContextWrapper;
import android.util.Log;

public class NotasHandler {
	
	private ContextWrapper cw;
	
	public NotasHandler(Context context){
		this.cw = new ContextWrapper(context);
	}
	
	public File getAppDataPath(){
		return cw.getDir("www/notas/nota", Context.MODE_PRIVATE);
	}
	
	public void downloadNotaFromURL(String downloadURL, String fileName){
		
		try{
			URL url = new URL(downloadURL);
			
			URLConnection ucon = url.openConnection();
			
			InputStream is = ucon.getInputStream();
			BufferedInputStream bis = new BufferedInputStream(is);

			ByteArrayBuffer baf = new ByteArrayBuffer(5000);
			
			int current = 0;
			while ((current = bis.read()) != -1) {
				baf.append((byte) current);
			}
			
			FileOutputStream fos = new FileOutputStream(new File(getAppDataPath(),fileName)); 
			fos.write(baf.toByteArray());
			fos.flush();
			fos.close();
			Log.i("NOTA_DOWNLOADED", "Downloaded => " + fileName);
		
		}catch(MalformedURLException e){
			e.printStackTrace();
		}catch(IOException e){
			e.printStackTrace();
		}
		
	}
	
	
	public boolean downloadProject(File unzipDir){
		try{
			URL url = new URL(NotasConstants.DOWNLOAD_ZIPED_PROJECT);
			
			URLConnection ucon = url.openConnection();
			
			InputStream is = ucon.getInputStream();
			BufferedInputStream bis = new BufferedInputStream(is);

			ByteArrayBuffer baf = new ByteArrayBuffer(5000);
			
			int current = 0;
			while ((current = bis.read()) != -1) {
				baf.append((byte) current);
			}
			
			FileOutputStream fos = new FileOutputStream(new File(unzipDir.getAbsolutePath(),"dfusion.zip")); 
			fos.write(baf.toByteArray());
			fos.flush();
			fos.close();
			
			return true;
		
		}catch(MalformedURLException e){
			e.printStackTrace();
			return false;
		}catch(IOException e){
			e.printStackTrace();
			return false;
		}
	}
	
	
	public void deleteNota(String fileName){
		
		try{
			File nota = new File(getAppDataPath(), fileName);
			if(nota.exists()){
				nota.delete();
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	
}
