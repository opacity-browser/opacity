 (function() {
     // 1. 클릭 이벤트를 직접 생성하여 방어 로직 우회 (스킵 버튼용)
     const simulateClick = (element) => {
         if (!element) return;
         ['mousedown', 'mouseup', 'click'].forEach(mouseEvent => {
             element.dispatchEvent(new MouseEvent(mouseEvent, {
                 view: window, bubbles: true, cancelable: true, buttons: 1
             }));
         });
     };

     const runCleaner = () => {
         const video = document.querySelector('video');
         const adShowing = document.querySelector('.ad-interrupting, .ad-showing');
         
         // [A] 영상 광고 스킵 로직
         if (adShowing && video) {
             video.muted = true; // 광고 소리 끔
             video.playbackRate = 16; // 16배속 가속
             if (isFinite(video.duration) && video.currentTime < video.duration) {
                 video.currentTime = video.duration - 0.1; // 끝으로 이동
             }
         }

         // [B] 스킵 버튼 자동 클릭 (다양한 선택자 대응)
         const skipButtons = [
             '.ytp-ad-skip-button',
             '.ytp-ad-skip-button-modern',
             '#dismiss-button' // 팝업 닫기 버튼 포함
         ];
         skipButtons.forEach(selector => {
             const btn = document.querySelector(selector);
             if (btn && btn.offsetHeight > 0) { // 화면에 보이는 경우만
                 simulateClick(btn);
             }
         });

         // [C] 프리미엄 팝업(Mealbar) 및 안내창 강제 제거
         // 질문하신 ytd-popup-container와 Mealbar를 직접 타겟팅합니다.
         const overlays = [
             'ytd-mealbar-promo-renderer',
             'ytd-enforcement-message-view-model',
             'yt-upsell-dialog-renderer',
             'tp-yt-paper-dialog'
         ];
         overlays.forEach(selector => {
             const el = document.querySelector(selector);
             if (el) {
                 // 특정 다이얼로그가 'Premium' 관련 내용을 포함할 때만 삭제 (실제 안내창 오작동 방지)
                 if (el.innerText.includes("Premium") || el.innerText.includes("광고") || el.innerText.includes("무료")) {
                     // 상위 컨테이너가 있다면 같이 삭제
                     const container = el.closest('ytd-popup-container') || el;
                     container.remove();
                 }
             }
         });
     };

     // [D] CSS를 통한 광고 레이어 원천 봉쇄
     const style = document.createElement('style');
     style.innerHTML = `
         ytd-ad-slot-renderer, .ytp-ad-overlay-container, #player-ads { 
             display: none !important; 
         }
     `;
     document.head.appendChild(style);

     // 0.3초마다 반복 실행하여 동적 생성 요소 대응
     setInterval(runCleaner, 200);
 })();
