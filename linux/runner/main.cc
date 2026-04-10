#include "my_application.h"

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char** argv) {
  // IME 지원: 한글 등 CJK 입력을 위한 환경 변수 설정
  if (getenv("GTK_IM_MODULE") == NULL) {
    setenv("GTK_IM_MODULE", "ibus", 0);
  }
  if (getenv("XMODIFIERS") == NULL) {
    setenv("XMODIFIERS", "@im=ibus", 0);
  }

  // ibus 데몬이 실행 중이지 않으면 백그라운드로 시작
  if (system("pgrep -x ibus-daemon > /dev/null 2>&1") != 0) {
    system("ibus-daemon -drx 2>/dev/null");
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
