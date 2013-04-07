package com.educar.campo.utils;

import java.io.IOException;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;

import android.util.Log;

public class HttpUtil {
	public static JSONArray getRequest(String url) {
		try {
			HttpClient httpClient = new DefaultHttpClient();
			HttpGet del = new HttpGet(url);
			del.setHeader("content-type", "application/Json");
			HttpResponse resp = httpClient.execute(del);
			String respStr = EntityUtils.toString(resp.getEntity());
			JSONArray respJSON = new JSONArray(respStr);
			return respJSON;
		} catch (Exception e) {
			Log.d("GetReqError", e.getMessage());
			return null;
		}
	}

	public static String postRequest(String url, List<NameValuePair> valores) {
		String respuesta = "";
		try {
			HttpClient httpclient = new DefaultHttpClient();
			HttpPost httppost = new HttpPost(url);
			httppost.setEntity(new UrlEncodedFormEntity(valores));
			HttpResponse response = httpclient.execute(httppost);
			respuesta = EntityUtils.toString(response.getEntity());
		} catch (ClientProtocolException e) {
		} catch (IOException e) {
		}
		return respuesta;
	}
}
