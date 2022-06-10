<template>
  <div>
    <!-- override html and head -->
    <Html :lang="locale">
    <BaseMeta :title="route.meta.title ?? 'Home'" :description="description" :url="route.fullPath">
      <Meta property="og:site_name" :content="website" />
      <Meta property="og:image" :content="`http://${website}/social-card.jpg`" />
      <!-- Twitter related -->
      <Meta name="twitter:image" :content="`http://${website}/social-card.jpg`" />
      <Meta name="twitter:card" content="summary_large_image" />
      <Meta name="twitter:image:alt" :content="website" />
      <Meta name="twitter:site" content="@btspoony" />
      <!-- Favicons -->
      <Link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
      <Link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
      <Link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
      <Link rel="manifest" href="/site.webmanifest" />
    </BaseMeta>

    </Html>

    <!-- Layout -->
    <NuxtLayout class="bg-base-100">
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup>
const route = useRoute();
const locale = useLocale();

useHead({
  titleTemplate: "%s - Floid, A DID Protocol on Flow blockchain",
});

// ----- Data -----

const description = ref(
  "A DID Protocol on Flow blockchain, binding addresses from EVM compatible blockchains."
);
const website = ref("floid.pro");
</script>
