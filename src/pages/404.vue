<template>
  <main class="max-w-full hero min-h-[86vh] bg-base-100">
    <div class="page-container">
      <div class="hero-content flex-col m-2">
        <div class="max-w-md text-center p-2">
          <h1 class="text-5xl font-bold pb-8 drop-shadow-md">Page Not Found</h1>
          <NuxtLink to="/" class="link-highlight">
            <ArrowLeftIcon class="inline-block h-4" /> back to home
          </NuxtLink>
        </div>
        <div class="object-cover w-[480px] h-[520px] bg-[url('assets/image/home-flow.png')]"></div>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ArrowLeftIcon } from "@heroicons/vue/outline";

definePageMeta({
  title: "Page Not Found",
  layout: "pure",
});
</script>
