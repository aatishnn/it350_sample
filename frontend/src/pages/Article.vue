<template>
  <div>
    <div v-if="loading">Loading article....</div>
    <div v-else>
      <h1>{{ article.title }}</h1>
      <p>{{ article.content }}</p>
    </div>
  </div>
</template>

<script>
import Api from "../api";

export default {
  name: "ArticleDetail",
  data: function () {
    return {
      loading: false,
      article: null,
    };
  },
  created: function () {
    this.loading = true;
    Api.getArticleDetail(this.$route.params.id).then((res) => {
      this.article = res.data[0];
      this.loading = false;
    });
  },
};
</script>