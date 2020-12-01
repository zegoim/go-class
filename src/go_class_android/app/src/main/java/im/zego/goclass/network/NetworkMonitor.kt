package im.zego.goclass.network

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.os.Build
import android.util.Log


class NetworkMonitor(val context: Context) {
    private val TAG = "NetworkMonitor"
    private val cm =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private var isConnected = true

    private val connectivityCallback = ConnectivityCallback()
    private val networkConnectChangedReceiver = NetworkConnectChangedReceiver()

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.registerDefaultNetworkCallback(connectivityCallback)
            val activeNetwork = cm.activeNetwork
            isConnected = activeNetwork != null
            activeNetwork?.let {
                val networkCapabilities = cm.getNetworkCapabilities(activeNetwork)!!
                val linkProperties = cm.getLinkProperties(activeNetwork)!!
            }
        } else {
            val intentFilter = IntentFilter()
            intentFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE")
//            intentFilter.addAction("android.net.wifi.WIFI_STATE_CHANGED")
//            intentFilter.addAction("android.net.wifi.STATE_CHANGE")
            context.registerReceiver(networkConnectChangedReceiver, intentFilter);
        }
    }

    fun isNetworkAvailable(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            val activeNetwork: NetworkInfo? = cm.activeNetworkInfo
            isConnected = activeNetwork?.isConnected == true
        }
        return isConnected
    }

    fun unRegisterListen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.unregisterNetworkCallback(connectivityCallback)
        } else {
            context.unregisterReceiver(networkConnectChangedReceiver)
        }
    }

    private fun notifyConnectedState(connected: Boolean) {
        isConnected = connected
    }

    inner class ConnectivityCallback : ConnectivityManager.NetworkCallback() {
        override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
            val connected = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            notifyConnectedState(connected)
        }

        override fun onLost(network: Network) {
            notifyConnectedState(false)
        }
    }

    inner class NetworkConnectChangedReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.d(TAG, "onReceive() called with: context = $context, intent = $intent")
            if (ConnectivityManager.CONNECTIVITY_ACTION == intent.action) {
                notifyConnectedState(isNetworkAvailable())
            }
        }
    }
}