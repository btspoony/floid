<template>
  <main class="max-w-full hero min-h-[75vh] mt-[10vh] bg-base-100">
    <div class="page-container grid grid-cols-1 gap-8 justify-center place-content-center">
      <ul class="steps">
        <li v-for="(one, index) in steps" :key="'step_' + index" :data-content="
          currentStep === index ? '' : one.isCompleted ? '✓' : undefined
        " :class="{
  step: true,
  'step-primary': one.isCompleted || currentStep === index,
}">
          {{ one.label }}
        </li>
      </ul>
      <div class="min-h-[50vh] place-self-center">DATA</div>
    </div>
  </main>
</template>

<script setup>
definePageMeta({
  title: "Setup Floid",
  layout: "default",
});

const flowAccount = useFlowAccount();

const steps = reactive([
  {
    label: "Connect",
    isCompleted: false,
  },
  {
    label: "Initialize",
    isCompleted: false,
  },
  {
    label: "Sign with Ethers",
    isCompleted: false,
  },
  {
    label: "Bind to Floid",
    isCompleted: false,
  },
]);

const currentStep = ref(0);

watchEffect(() => {
  if (flowAccount.value?.loggedIn) {
    if (currentStep.value === 0) {
      steps[0].isCompleted = true;
      currentStep.value = 1;
    }
  } else {
    currentStep.value = 0;
    for (const step of steps) {
      step.isCompleted = false;
    }
  }
});
</script>
