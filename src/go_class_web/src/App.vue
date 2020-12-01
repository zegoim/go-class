<template>
  <div id="app">
    <router-view />
  </div>
</template>
<style lang="scss">
@import './style/reset';

html,
body,
#app {
  @include wh(100%, 100%);
  margin: 0;
  padding: 0;
}

.draggable-area {
  -webkit-app-region: drag;
}

.draggable-none {
  -webkit-app-region: no-drag;
}

ul {
  list-style: none;
  margin: 0;
  padding: 0;
}

// @font-face {
//   font-family: 'ZgFont';
//   src: url('../public/SourceHanSansSC-Regular.otf'); // Firefox, Chrome, Safari, Opera
// }

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  user-select: none;
}
</style>
