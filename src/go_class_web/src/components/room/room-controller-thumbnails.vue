<!--
 * @Description: 缩略图组件
-->
<template>
  <el-drawer
    :title="$t('wb.wb_priview')"
    :modal="false"
    :visible="visible"
    direction="rtl"
    size="100%"
    :show-close="false"
  >
    <ul class="swiper-ul" ref="swiper" id="swiper">
      <li
        v-for="(i, index) in thumbnailsImg"
        :key="index"
        @click="handlePageChange_(index)"
        :class="activeIndex === index && 'active'"
      >
        <span>{{ index + 1 }}</span>
        <el-image class="thumbnails-image" :src="i" fit="contain" @error="handleError">
          <div slot="error" class="image-slot">
            <i class="el-icon-picture-outline"></i>
          </div>
        </el-image>
      </li>
    </ul>
  </el-drawer>
</template>

<script>
import { debounce } from '@/utils/tool'

export default {
  name: 'RoomControllerThumbnails',
  props: ['thumbnailsVisible'],
  inject: ['zegoWhiteboardArea'],
  data() {
    return {
      activeIndex: 0
    }
  },
  computed: {
    visible() {
      return this.zegoWhiteboardArea.isThumbnailsVisible
    },
    currPage() {
      return this.zegoWhiteboardArea.currPage
    },
    thumbnailsImg() {
      return this.zegoWhiteboardArea.thumbnailsImg
    }
  },
  watch: {
    visible(val) {
      if (val) {
        this.zegoWhiteboardArea.getThumbnailUrlList()
        this.activeIndex = this.currPage - 1
        this.$nextTick(() => {
          this.elementScrollTo(this.activeIndex)
        })
      }
    },
    currPage(num) {
      if (num < 1) return
      this.activeIndex = num - 1
      this.elementScrollTo(this.activeIndex)
    }
  },
  mounted() {
    this.handlePageChange_ = debounce(this.handlePageChange, 500, true)
  },
  methods: {
    handlePageChange(index) {
      this.activeIndex = index
      this.elementScrollTo(index)
      // 文件页码从1开始
      this.zegoWhiteboardArea.flipPage(index + 1)
    },

    elementScrollTo(index) {
      const el = document.getElementById('swiper')
      if (!el) return

      const elClientHeight = document.querySelectorAll('#swiper li')[0]?.clientHeight
      const scrollToNum = elClientHeight * (index - 1)
      el.scrollTo({
        top: scrollToNum,
        behavior: 'smooth'
      })
    },

    handleError() {
      console.warn('有略缩图加载失败！')
      this.zegoWhiteboardArea.setThumbnailsStatus(false)
    },
    open() {
      this.zegoWhiteboardArea.setThumbnailsVisible(true)
    },
    close() {
      this.zegoWhiteboardArea.setThumbnailsVisible(false)
    }
  }
}
</script>
<style lang="scss">
.el-drawer__wrapper {
  position: fixed;
  right: 0;
  top: 0;
  bottom: 0;
  width: 256px;
  left: auto !important;
  overflow: initial !important;
  height: 100%;
  background-color: #fbfcff;
  .el-drawer {
    @include box-shadow(3px 3px 20px rgba(0, 0, 0, 0.2));
    .el-drawer__header {
      margin-bottom: 0;
      padding: 10px 26px;
      text-align: left;
      @include sc(14px, #18191a);
    }

    .el-drawer__close-btn {
      @include sc(12px, #909399);
    }

    .el-drawer__body {
      height: 100%;
    }
  }
}

:focus {
  outline: 0;
}

.swiper-ul {
  height: 100%;
  padding-bottom: 40px;
  overflow-y: scroll;

  &::-webkit-scrollbar {
    width: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background-color: rgba(177, 180, 188, 0.5);
    border-radius: 2px;
  }

  li {
    display: flex;
    padding: 10px 0 10px 22px;

    span {
      display: inline-block;
      width: 30px;
      margin-right: 8px;
      vertical-align: top;
      text-align: center;
      @include sc(14px, #b1b4bb);
    }

    .thumbnails-image {
      @include wh(160px, 90px);
      border-radius: 4px;
      background-color: #fff;
      border: 1px solid #f0f0f0;
      box-sizing: content-box;
      overflow: hidden;
      .image-slot {
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
      }
    }

    &.active {
      background-color: #f0f4ff;

      span {
        color: #0044ff;
      }

      .thumbnails-image {
        border: 1px solid #0044ff;
      }
    }
  }
}
</style>
