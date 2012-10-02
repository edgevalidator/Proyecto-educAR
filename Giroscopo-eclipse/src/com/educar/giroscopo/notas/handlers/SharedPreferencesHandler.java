package com.educar.giroscopo.notas.handlers;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

public class SharedPreferencesHandler {
	
	private static final String APP_SHARED_PREFS = "NotasPrefs";
	private static SharedPreferences appSharedPrefs;
	private static Editor prefsEditor;
	
	
	public String getValue(String key){
		try{
			return appSharedPrefs.getString(key, "");
		}catch(Exception e){
			return "";
		}
	}
	
	public void setValue(String key, String value){
		prefsEditor.putString(key, value);
		prefsEditor.commit();
	}
	
	public SharedPreferencesHandler(Context context){
		this.appSharedPrefs = context.getSharedPreferences(APP_SHARED_PREFS, Activity.MODE_PRIVATE);
		this.prefsEditor = appSharedPrefs.edit();	
	}
	
	
}
