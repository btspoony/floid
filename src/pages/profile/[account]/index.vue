<script setup lang="ts">
definePageMeta({
  middleware: (to, from) => {
    return navigateTo(`/profile/${to.params.account}/portfolio`);
  },
});
</script>
