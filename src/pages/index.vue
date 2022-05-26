<template>
  <main class="max-w-full">
    <section class="hero min-h-screen bg-gradient-to-b from-base-100 to-primary-content">
      <BaseContainer>
        <div class="hero-content text-center">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold">Hello there</h1>
            <p class="py-6">
              Provident cupiditate voluptatem et in. Quaerat fugiat ut assumenda
              excepturi exercitationem quasi. In deleniti eaque aut repudiandae
              et a id nisi.
            </p>
            <button class="btn btn-primary">Get Started</button>
          </div>
        </div>
      </BaseContainer>
    </section>
    <section class="hero min-h-screen bg-base-100">
      <BaseContainer>
        <div class="hero-content text-center">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold">Some Intro A</h1>
          </div>
        </div>
      </BaseContainer>
    </section>
    <section class="hero min-h-screen bg-secondary text-secondary-content">
      <BaseContainer>
        <div class="hero-content text-center">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold">Some Intro B</h1>
          </div>
        </div>
      </BaseContainer>
    </section>
    <section id="about" class="hero min-h-screen bg-base-100">
      <BaseContainer>
        <div class="hero-content text-center">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold">About</h1>
          </div>
        </div>
      </BaseContainer>
    </section>
  </main>
</template>

<script setup>
definePageMeta({
  title: "Home",
});
</script>
