package com.example.AllowMeBridge

import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull

import br.com.allowme.android.allowmesdk.AddPersonCallback;
import br.com.allowme.android.allowmesdk.AllowMe;
import br.com.allowme.android.allowmesdk.CollectCallback;
import br.com.allowme.android.allowmesdk.SetupCallback;
import br.com.allowme.android.allowmesdk.StartCallback;
import br.com.allowme.android.allowmesdk.domain.model.Address;
import br.com.allowme.android.allowmesdk.domain.model.Person;
import br.com.allowme.android.allowmesdk.biometry.model.BiometryResult
import br.com.allowme.android.allowmesdk.biometry.exception.BiometryErrors

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "br.com.samples.allowme/sdk"

    lateinit var mAllowMe: AllowMe
    private val TAG = "AllowMeFlutterApp"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mAllowMe = AllowMe.getInstance(
            applicationContext,
            applicationContext.getString(R.string.api_key)
        )
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "collect" -> getContextual(result)
                "setup" -> initContextual(result)
                "addPerson" -> addPerson(result)
                "start" -> startContextual(result)
                else -> result.notImplemented()
            }
            
        }
    }

    private fun startContextual(result: MethodChannel.Result){
        Log.d(TAG, "setup contextual called!")
        mAllowMe.setup(object: SetupCallback{
            override fun success(){
                Log.d(TAG,"setup Contextual finished")
                result.success("Setup contextual success")
            }
            override fun error(throwable: Throwable){
                Log.d(TAG,"setup erro: " + throwable)
                result.error("Setup failed: ", throwable.message, null)
            }
        })
    }

    private fun getContextual(result: MethodChannel.Result){
        Log.d(TAG,"collect contextual called")
        mAllowMe.collect(object: CollectCallback{
            override fun success(collect: String){
                Log.d(TAG,"Collect success: " + collect)
                result.success("Collect success")
            }
            
            override fun error(throwable: Throwable){
                Log.d(TAG,"Collect failed. " + throwable)
                result.error("Collect Failed: ", throwable.message,null)
            }
        })
    }

    private fun initContextual(result: MethodChannel.Result){
        Log.d(TAG,"start onboarding called!")
        mAllowMe.start(object: StartCallback{
            override fun success() {
                Log.d(TAG,"Setup success")
                Log.d(TAG,"Start onboarding finished")
                result.success("start Success!")
            }
        
            override fun error(throwable: Throwable) {
                Log.d(TAG,"Setup failed", throwable)     
                result.error("start Failed ",throwable.message,null)           
            }
        })
    }

    private fun addPerson(result: MethodChannel.Result) {
        Log.d(TAG, "AddPerson called!");

        val address = Address(
            "Nome da Rua", //Rua
            "city", // Cidade
            "state",// Estado
            100, // Número
            "neighbourhood", // Bairro
            "zipCode", // Cep
            "unit",
            "country",
            null
        )

        val person = Person(
            "Nome Completo", //Nome Completo
            "00000000000", // Cpf
            address,
            "email",
            "phone"
        )

        mAllowMe.addPerson(person, object : AddPersonCallback {
            override fun success() {
                Log.d(TAG, "addPerson succeeded!")
                result.success("Person added!")
            }

            override fun error(throwable: Throwable) {
                Log.d(TAG, "addPerson failed")
                result.error("addPerson failed", throwable.message, null)
            }
        })
    }

  
}
