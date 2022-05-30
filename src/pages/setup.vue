<template>
  <main class="max-w-full hero min-h-[75vh] pt-[10vh]">
    <div class="page-container grid grid-cols-1 gap-8 justify-center place-content-center">
      <ul class="steps">
        <li v-for="(one, index) in steps" :key="'step_' + index" :data-content="getStepContent(one, index)" :class="{
          step: true,
          'step-primary': one.isCompleted || currentStep === index,
        }">
          {{ one.label }}
        </li>
      </ul>
      <div class="card min-w-[90%] min-h-[50vh]">FORM</div>
    </div>
  </main>
</template>

<script setup lang="ts">
definePageMeta({
  title: "Setup Floid",
  layout: "default",
});

const flowAccount = useFlowAccount();

type StepData = {
  label: string;
  isCompleted: boolean;
};

const steps = reactive<StepData[]>([
  {
    label: "Connect Wallet",
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

function getStepContent(item: StepData, index: number): string {
  return currentStep.value === index ? "" : item.isCompleted ? "✓" : undefined;
}
</script>
