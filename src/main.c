#include <libopencm3/cm3/nvic.h>
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/timer.h>

void tim2_isr() {
  if (timer_get_flag(TIM2, TIM_SR_UIF)) {
    timer_clear_flag(TIM2, TIM_SR_UIF);
    gpio_toggle(GPIOA, GPIO5);
  }
}

int main(void) {
  rcc_periph_clock_enable(RCC_GPIOA);
  rcc_periph_clock_enable(RCC_TIM2);
  rcc_clock_setup_pll(&rcc_hse_8mhz_3v3[RCC_CLOCK_3V3_84MHZ]);
  gpio_mode_setup(GPIOA, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO5);

  timer_set_mode(TIM2, TIM_CR1_CKD_CK_INT, TIM_CR1_CMS_EDGE, TIM_CR1_DIR_UP);
  timer_set_period(TIM2, 9999);
  timer_set_prescaler(TIM2, rcc_ahb_frequency / 10000 - 1);
  timer_enable_irq(TIM2, TIM_DIER_UIE);
  nvic_enable_irq(NVIC_TIM2_IRQ);
  timer_enable_counter(TIM2);
  while (1) {
  }

  return 0;
}
