<template>
  <main class="max-w-full hero min-h-[88vh] pt-16">
    <div class="page-container grid grid-cols-1 gap-8 justify-center place-content-center">
      <ul class="steps">
        <li v-for="(one, index) in steps" :key="'step_' + index" :data-content="getStepContent(one, index)" :class="{
          step: true,
          'step-primary': isStepCompleted(index) || currentStep === index,
        }">
          {{ one.label }}
        </li>
      </ul>
      <div class="panel min-w-[90%]">
        <div class="hero min-h-[50vh]">
          <div class="hero-content w-full flex-col lg:flex-row gap-4 text-center lg:text-left">
            <div class="flow-ball flex-none"></div>
            <NuxtPage />
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
definePageMeta({
  title: "Setup Floid",
  layout: "default",
});

const flowAccount = useFlowAccount();
const route = useRoute();
const router = useRouter();

type StepData = {
  label: string;
  page: string;
  step: number;
};

const steps = reactive<StepData[]>([
  {
    label: "Connect Wallet",
    page: "",
    step: 0,
  },
  {
    label: "Initialize",
    page: "init",
    step: 1,
  },
  {
    label: "Sign with Ethers",
    page: "sign",
    step: 2,
  },
  {
    label: "Bind to Floid",
    page: "bind",
    step: 3,
  },
]);

const currentStep = useCurrentSetupStep();
const currentSetupMessage = useCurrentSetupMessage();

watchEffect(() => {
  const paths = route.path.split("/");
  if (!route.path.startsWith("/setup")) return;

  // check last path
  let lastPath = paths[paths.length - 1];
  if (lastPath === "setup") {
    lastPath = "";
  }

  let currentSetupIndex = 0;
  // update step when key is not null
  if (currentSetupMessage.value !== null) {
    const found = steps.find((one) => one.page === lastPath);
    if (found) {
      currentSetupIndex = found.step;
    }
  }

  // update step by login status
  if (flowAccount.value?.loggedIn) {
    if (currentSetupIndex === 0 || currentStep.value === 0) {
      currentSetupIndex = 1;
    }
  } else {
    currentSetupIndex = 0;
  }

  const current = steps[currentSetupIndex];
  if (current.page !== lastPath) {
    router.replace("/setup/" + current.page);
  } else {
    currentStep.value = currentSetupIndex;
  }
});

function getStepContent(item: StepData, index: number): string {
  return currentStep.value === index
    ? ""
    : isStepCompleted(index)
      ? "✓"
      : undefined;
}
function isStepCompleted(index: number): boolean {
  const step = steps[index];
  return step && step.step <= currentStep.value;
}
</script>
