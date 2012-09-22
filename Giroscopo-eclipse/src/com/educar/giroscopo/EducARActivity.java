package com.educar.giroscopo;

import android.app.Activity;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import android.util.Log;
import android.widget.FrameLayout;
import ti.dfusionmobile.tiComponent;



public class EducARActivity extends Activity {
    
	private FrameLayout _frameLayout;
	private tiComponent _tiComponent;
	
	/** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	Log.e("MainActivity", "onCreate");
        super.onCreate(savedInstanceState);
        _tiComponent = new tiComponent(this);
       
    }
    
    @Override
    public void onStart() {
	    Log.i("MainActivity", "onStart");   
	    // init the D'Fusion mobile component :
	    _frameLayout = new FrameLayout(this);
	    _tiComponent.initialize(_frameLayout);
	    _tiComponent.activateAutoFocusOnDownEvent(true);
	    // attach to the window :
	    setContentView(_frameLayout);
	    super.onStart();
	    // load a scenario (_frameLayout and _tiComponent
	    // must be created and initialized)
	    ApplicationInfo appInfo = null;
	    PackageManager packMgmr = getApplicationContext().getPackageManager();
	    try {
	    	appInfo = packMgmr.getApplicationInfo(getPackageName(), 0);
	    } catch (NameNotFoundException e) {
	    	e.printStackTrace();
	    	throw new RuntimeException("Unable to locate assets, aborting...");
	    }
	    String dpdfile = appInfo.sourceDir + "/assets/Giroscopo.dpd";
	    _tiComponent.loadScenario(dpdfile);
	    // don't forget to play your scenario:
	    _tiComponent.playScenario();
    }
    
    @Override
    public void onResume(){
	    Log.i("MainActivity", "onResume");
	    super.onResume();
	    // we re-create the GL Context and reload the scenario
	    _tiComponent.onResume();
	    // play the scenario
	    _tiComponent.playScenario();
    }
    @Override
    public void onPause() {
    	Log.i("MainActivity", "onPause");
		super.onPause();
		// we pause the scenario
	    _tiComponent.pauseScenario();
	    // we notify the onPause event to the component :
	    // medias are released but the library is not unloaded.
	    _tiComponent.onPause();
    }
    @Override
    public void onStop() {
	    Log.i("MainActivity", "onStop");
	    super.onStop();
	    // the component is closed, media are unloaded
	    // 3d view and videocapture are destroyed.
	    _tiComponent.terminate();
    }
    @Override
    public void onDestroy() {
	    Log.i("MainActivity", "onDestroy");
	    super.onDestroy();
	    // delete everything.
	    _frameLayout = null;
	    _tiComponent = null;
    }
    
}