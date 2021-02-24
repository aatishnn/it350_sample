<template>
  <div>
    <div v-if="loading">Loading articles....</div>
    <router-link to="admin/add" tag="b-button" class="float-right"
      >Add article</router-link
    >
    <br /><br />
    <b-table-simple hover small caption-top responsive>
      <b-thead>
        <b-tr>
          <b-th>ID</b-th>
          <b-th>Title</b-th>
          <b-th>Published</b-th>
          <b-th>Actions</b-th>
        </b-tr>
      </b-thead>
      <b-tbody>
        <b-tr v-for="article in articles" :key="article.articleid">
          <b-td>{{ article.articleid }}</b-td>
          <b-td>{{ article.title }}</b-td>
          <b-td>{{ article.ispublished }}</b-td>
          <b-td>
            <b-button-group>
              <b-button
                variant="outline-primary"
                :to="`/admin/edit/${article.articleid}`"
                >Edit</b-button
              >
              <b-button
                variant="outline-info"
                @click="() => publishArticle(article.articleid)"
                >Publish</b-button
              >
              <b-button
                variant="outline-danger"
                @click="() => deleteArticle(article.articleid)"
                >Delete</b-button
              >
            </b-button-group>
          </b-td>
        </b-tr>
      </b-tbody>
    </b-table-simple>
  </div>
</template>

<script>
import Api from "../api";

export default {
  name: "AdminArticleList",
  data: function () {
    return {
      loading: false,
      articles: [],
    };
  },
  created: function () {
    this.loadArticles();
  },

  methods: {
    loadArticles() {
      this.loading = true;
      this.articles = [];
      Api.getArticles().then((res) => {
        this.articles = res.data;
        this.loading = false;
      });
    },
    publishArticle(articleid) {
      Api.publishArticle(articleid)
        .then(() => {
          this.loadArticles();
        })
        .catch((err) => {
          console.log(err);
        });
    },

    deleteArticle(articleid) {
      Api.deleteArticle(articleid)
        .then(() => {
          this.loadArticles();
        })
        .catch((err) => {
          console.log(err);
        });
    },
  },
};
</script>