<template>
  <div :data-theme="dataTheme">
    <!-- override html and head -->
    <Html :lang="locale" :class="theme">

    <Head>
      <Title>{{ route.meta.title ?? "Home" }}</Title>
      <Meta name="description" :content="description" />
      <Meta property="og:type" content="article" />
      <Meta property="og:title" :content="`${route.meta.title ?? 'Home'} - Floid`" />
      <Meta property="og:description" :content="description" />
      <Meta property="og:url" :content="'https://' + website" />
      <Meta property="og:site_name" :content="website" />
      <Meta property="og:image" :content="`http://${website}/social-card.jpg`" />
      <!-- Twitter related -->
      <Meta name="twitter:image" :content="`http://${website}/social-card.jpg`" />
      <Meta name="twitter:card" content="summary_large_image" />
      <Meta name="twitter:image:alt" :content="website" />
      <Meta name="twitter:title" :content="description" />
      <Meta name="twitter:description" :content="description" />
      <Meta name="twitter:site" content="@btspoony" />
      <!-- Favicons -->
      <Link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
      <Link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
      <Link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
      <Link rel="manifest" href="/site.webmanifest" />
    </Head>

    </Html>

    <!-- Layout -->
    <BaseHeader />
    <NuxtPage />
    <BaseFooter />
  </div>
</template>

<script setup>
const route = useRoute();
const locale = useLocale();
const theme = useTheme();

useHead({
  titleTemplate: "%s - Floid, A DID Protocol on Flow blockchain",
});

// ----- Data -----

const dataTheme = computed(() => {
  return theme.value === "dark" ? "forest" : "floid";
});

const description = ref(
  "A DID Protocol on Flow blockchain, binding addresses from EVM compatible blockchains."
);
const website = ref("floid.pro");
</script>
