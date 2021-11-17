package im.zego.goclass;

/**
 * 独立部署业务后台之后，替换相应环境的地址
 * 业务后台源码及部署方案请参考：https://github.com/zegoim/go-class/blob/release/express/docs/GettingStartedServer.md
 */
public class BackendApiConstants {
    // 业务后台地址（正式环境）
    public final static String BACKEND_API_URL = YOUR_BACKEND_URL;

    // 业务后台地址（正式环境，海外）
    public final static String BACKEND_API_URL_OVERSEAS = YOUR_BACKEND_URL;
}
