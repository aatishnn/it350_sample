<template>
  <div>
    <b-jumbotron>
      <p>Welcome to the IT350 blog!</p>
    </b-jumbotron>
    <br />
    <div v-if="loading">Loading articles....</div>
    <ul v-else>
      <li v-for="article in articles" :key="article.articleid">
        <router-link :to="`article/${article.articleid}`">{{
          article.title
        }}</router-link>
      </li>
    </ul>
  </div>
</template>

<script>
import Api from "../api";

export default {
  name: "Home",
  data: function () {
    return {
      loading: false,
      articles: [],
    };
  },
  created: function () {
    this.loading = true;
    Api.getArticles().then((res) => {
      this.articles = res.data;
      this.loading = false;
    });
  },
};
</script>