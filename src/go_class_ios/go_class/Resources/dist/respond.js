window.htmlfont = '';
window.isMobile = false;
!(function(window) {
    const n = document.documentElement;
    let rootfont;
    const i = document.createElement('style');
    n.firstElementChild.appendChild(i);

    function infinite() {
        // var docW = document.documentElement.clientWidth;
        let docW = window.innerWidth;

        if (navigator.userAgent.match(/Android|BlackBerry|iPhone|iPad|iPod|Opera Mini|IEMobile/i)) {
            isMobile = true;
        }
        if (docW < 320) {
            docW = 320;
            rootfont = (100 / 750) * docW;
            i.innerHTML = 'html{font-size:' + rootfont + 'px!important;visibility: visible;}';
        } else if (docW <= 750) {
            rootfont = (100 / 750) * docW;
            i.innerHTML = 'html{font-size:' + rootfont + 'px!important;visibility: visible;}';
        } else {
            i.innerHTML = 'html{visibility: visible;}';
        }
        htmlfont = rootfont;
    }
    window.addEventListener(
        'resize',
        function() {
            infinite();
        },
        !1,
    );

    window.addEventListener(
        'pageshow',
        function(e) {
            // pageshow无论这个页面是新打开的还是在往返缓存中的，都会在这个页面显示的时候触发。新打开的会在load后触发。
            // event对象中有一个persisted属性，是true时代表是从往返缓存中恢复的。
            // 缓存完全保存了整个页面，包括JS的执行状态，这就意味着不会再触发load事件。
            // 防止此情况发生，做一个判断，执行字体设置函数
            e.persisted && infinite();
        },
        !1,
    ),
        infinite();
})(window);
