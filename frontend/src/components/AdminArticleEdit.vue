<template>
  <div>
    <b-breadcrumb>
      <b-breadcrumb-item to="/admin"> Admin </b-breadcrumb-item>
      <b-breadcrumb-item active>Edit Article</b-breadcrumb-item>
    </b-breadcrumb>
    <div v-if="loading">Loading article...</div>
    <div v-else class="card card-container p-4">
      <form name="form" @submit.prevent="handleSave">
        <div>
          <div class="form-group">
            <label for="username">Article Id</label>
            <input
              v-model="article.articleid"
              type="text"
              class="form-control"
              name="id"
              readonly
            />
          </div>
          <div class="form-group">
            <label for="username">Title</label>
            <input
              v-model="article.title"
              type="text"
              class="form-control"
              name="title"
            />
          </div>
          <div class="form-group">
            <label for="content">content</label>
            <textarea
              v-model="article.content"
              class="form-control"
              name="content"
              rows="20"
            />
          </div>
          <div class="form-group">
            <button class="btn btn-primary btn-block" :disabled="saving">
              <span
                v-show="saving"
                class="spinner-border spinner-border-sm"
              ></span>
              <span>Save</span>
            </button>
          </div>
        </div>
      </form>

      <div v-if="message" class="alert alert-danger">
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script>
import Api from "../api";

export default {
  name: "AdminArticleEdit",
  data: function () {
    return {
      loading: false,
      saving: false,
      article: null,
    };
  },
  methods: {
    loadArticleDetail() {
      this.loading = true;
      Api.getArticleDetail(this.$route.params.id).then((res) => {
        this.article = res.data[0];
        this.loading = false;
      });
    },
    handleSave() {
      this.saving = true;
      Api.updateArticle(this.article)
        .then(() => {
          this.saving = false;
          this.$router.push("/admin");
        })
        .catch((error) => {
          console.log(error);
          if (error.response) {
            this.message = error.response.data.message;
          }
          this.loading = false;
        });
    },
  },
  created: function () {
    this.loadArticleDetail();
  },
};
</script>