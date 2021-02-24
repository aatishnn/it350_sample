<template>
  <div>Logging you out...</div>
</template>

<script>
import { deleteJwtToken } from "../auth";
export default {
  name: "Logout",
  mounted: function () {
    deleteJwtToken();
    this.$router.push({ path: "/" });
  },
};
</script>