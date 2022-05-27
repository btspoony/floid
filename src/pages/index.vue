<template>
  <main class="max-w-full">
    <section class="hero min-h-screen bg-gradient-to-b from-base-100 to-primary-content">
      <BaseContainer>
        <div class="hero-content flex-col lg:flex-row-reverse mt-4 lg:mt-0">
          <img class="object-cover max-w-sm rounded-lg" src="~/assets/image/home-flow.png" alt="Flow Home" />
          <div class="max-w-sm lg:max-w-lg prose text-center lg:text-left p-2 lg:px-4">
            <h3 class="text-5xl font-bold drop-shadow-md">Welcome to FLOID</h3>
            <p class="font-semibold">
              A <span class="text-secondary-focus">DID</span> Protocol on
              <span class="text-secondary-focus">Flow blockchain</span>.
            </p>
            <p class="py-2 text-2xl">
              Associate
              <span :class="[
                'inline-block font-semibold transition-all duration-500',
                isShowup
                  ? 'translate-y-0 opacity-100'
                  : 'translate-y-2 opacity-0',
              ]">{{ loopWords[currentWordIdx] }}</span><br />
              to your Flow account.
            </p>
            <button class="btn btn-primary">Get Started</button>
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

const loopWords = ref([
  "Ethereum Address",
  "Twitter Account",
  "Discord Account",
  "Any Web3 Identity",
]);
const currentWordIdx = ref(0);
const isShowup = ref(true);

let intervalId;

onMounted(() => {
  let count = 5;
  intervalId = setInterval(() => {
    let update = false;
    if (isShowup.value) {
      if (count === 0) {
        update = true;
        count = 5;
      } else {
        count--;
      }
    } else {
      update = true;
    }
    if (update) {
      isShowup.value = !isShowup.value;
    }
  }, 500);
});

watch(isShowup, (newVal, oldVal) => {
  if (newVal === false) {
    setTimeout(() => {
      currentWordIdx.value =
        (currentWordIdx.value + 1) % loopWords.value.length;
    }, 500);
  }
});

onBeforeUnmount(() => {
  clearInterval(intervalId);
});
</script>
