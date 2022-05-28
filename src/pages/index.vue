<template>
  <main class="max-w-full">
    <section class="hero min-h-screen bg-gradient-to-b from-base-100 to-primary-content">
      <div class="page-container">
        <div class="hero-content flex-col lg:flex-row-reverse mt-4 lg:mt-0">
          <div class="object-cover w-[480px] h-[520px] bg-[url('assets/image/home-flow.png')]"></div>
          <div class="max-w-sm lg:max-w-lg prose text-center lg:text-left p-2 lg:px-4">
            <h3 class="text-5xl font-bold drop-shadow-md">Welcome to FLOID</h3>
            <p class="font-semibold">
              A <span class="text-secondary-focus">DID</span> Protocol on
              <span class="text-secondary-focus">Flow blockchain</span>.
            </p>
            <p class="py-2 text-2xl">
              Associate
              <WidgetShowupBlock class="font-semibold" @update="onShowupChanged">
                {{ loopWords[currentWordIdx] }} </WidgetShowupBlock><br />
              to your Flow account.
            </p>
            <button class="btn btn-primary" @click="onClickGetStart">
              Get Started
            </button>
          </div>
        </div>
      </div>
    </section>
    <section id="about" class="hero min-h-screen bg-base-100">
      <div class="page-container">
        <div class="hero-content text-center">
          <div class="max-w-md">
            <h1 class="text-5xl font-bold">About</h1>
          </div>
        </div>
      </div>
    </section>
  </main>
</template>

<script setup>
definePageMeta({
  title: "Home",
  layout: "default",
});

const loopWords = ref([
  "Ethereum Address",
  "Twitter Account",
  "Discord Account",
  "Any Web3 Identity",
]);
const currentWordIdx = ref(0);

function onShowupChanged() {
  currentWordIdx.value = (currentWordIdx.value + 1) % loopWords.value.length;
}

const router = useRouter();
const flowAccount = useFlowAccount();

function onClickGetStart() {
  if (flowAccount.value?.loggedIn) {
    router.push(`/profile/${flowAccount.value?.addr}`);
  } else {
    router.push("/setup");
  }
}
</script>
