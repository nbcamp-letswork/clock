# 📘 clock

iOS 기본 앱 시계의 알람, 스톱워치, 타이머 탭을 클론한 앱

<image src="https://github.com/user-attachments/assets/1707d7cc-8cd2-48ca-8cc2-70d06f1f9b27" width= "800" />

## 🗂 기술 스택 및 키워드

### 📱 iOS
- Swift
- UIKit
- RxSwift 
- SnapKit

### 💡 키워드
- CoreData
- MVVM (Input-Output) 
- Clean Architecture
- DIContainer

### ⚙️ 협업 & 기타
- Git / GitHub
- Figma
- Notion
- Slack

---

## 🧩 추가 기능

- ✅ 알람 그룹화
- ✅ 알람 위젯

---

## 🧪 프로젝트 구조

```bash
📦clock
├── App                          # 앱 진입점 (AppDelegate, SceneDelegate 등)
│
├── Data                         # 데이터 소스와의 통신 담당 (CoreData 등)
│   ├── Interface                # CoreData Storage 프로토콜 정의
│   │   └── Persistence
│   ├── Persistence              # CoreData 관련 모델 및 실제 구현
│   │   ├── Model
│   │   └── Persistence          # CoreData Storage 구현체
│   ├── Repository               # Repository 구현체
│   └── Error                    # Data 계층에서 사용하는 에러 정의
│
├── Domain                       # 앱의 핵심 비즈니스 로직을 담당
│   ├── Interface
│   │   ├── Repository           # Repository 프로토콜 정의
│   │   └── UseCase              # UseCase 인터페이스 정의
│   ├── UseCase                  # 구체적인 비즈니스 로직 구현
│   ├── Model                    # 도메인 모델 정의
│   └── Error                    # 도메인 계층에서 사용하는 에러 정의
│
├── Presentation                 # UI와 사용자 상호작용을 담당 (View, ViewModel 등)
│   ├── Model                    # ViewModel에서 사용하는 UI 전용 모델
│   │   └── TimerDisplay.swift
│   ├── Scene                    # 화면 단위로 분리된 기능들
│   │   ├── Stopwatch            # 스톱워치 화면
│   │   │   ├── ViewController
│   │   │   │   └── Subview      # 서브 컴포넌트 뷰
│   │   │   └── ViewModel
│   │   ├── Timer                # 타이머 화면
│   │   └── Alarm                # 알람 화면
│   ├── Component                # 재사용 가능한 UI 컴포넌트
│   ├── Factory                  # UI 컴포넌트 관련 메서드 팩토리
│   └── Extension                # UIKit, Foundation 등의 확장 메서드
│
├── Resource                     # 에셋, 폰트, 로컬라이즈 리소스 등
```

## CoreData 구조
![image](https://github.com/user-attachments/assets/75eaaa6e-5f00-46c6-a3f5-c8fdeb299a41)


## 🔥 기술적 도전 및 문제 해결

### 1. 타이머 업데이트 시 UI 반영되지 않은 문제
- Actor를 사용한 Data Race 해결
<image src="https://github.com/user-attachments/assets/9ae0374b-eb03-48fb-bbb9-26e6a142e942" width= "400" />

### 2. 스톱워치 동작 중 스크롤 버벅임 문제
| 방법 | 설명 | 화면 |
|------|------|------|
| 1️⃣ UITableViewDataSource | 전체 reload 방식 스크롤이 안 됨 (Bad) | <img src="https://github.com/user-attachments/assets/5d01fc94-e025-4c68-b70e-eaa6cd7be06e" width="150" /> |
| 2️⃣ UITableViewDiffableDataSource | 여전히 스크롤이 불안정함 (Still Bad) | <img src="https://github.com/user-attachments/assets/6a73b76f-9d78-46a3-87c5-1c1288344b7f" width="150" /> |
| 3️⃣ 최상단 랩만 update | 필요한 셀만 업데이트 (Good) | <img src="https://github.com/user-attachments/assets/2c5522c7-fd44-4494-8d1c-64ea79d9351a" width="150" /> |

### 3. CoreData 비동기 구현
- viewContext가 아닌 backgroundContext 사용
- async/await + withCheckedContinuation으로 Swift Concurrency 구현
<img width="500" alt="image" src="https://github.com/user-attachments/assets/ebc2ea31-e30c-4bfd-aae0-ce3a2c7866a8" />


### 4. 클린 아키텍처 원칙에 따라 관심사 분리
- CoreDataEntity와 DomainEntity 간 매핑 책임을 Repository가 담당
- Storage는 DomainEntity 타입 모르게 하기
- Repository는 CoreData 로직에 직접 접근하지 않기

| Before (기존 구현) | After (개선된 구현) |
|---------------------|----------------------|
| <img width="550" alt="기존 코드" src="https://github.com/user-attachments/assets/fd5fe155-5809-41f5-927a-cd0780479875" /> | <img width="350" alt="개선 코드" src="https://github.com/user-attachments/assets/0da63708-754d-4630-8a55-2218ee6e4067" /> |

### 5. Widget 구현
- AppGroup 사용
- Sandbox 외부에 데이터 저장
<img width="200" alt="image" src="https://github.com/user-attachments/assets/d454ec31-5683-4718-962a-647cb6a1645d" />

## 😂 아쉬운 점
- 스톱워치 타이머 시작 중 앱 종료 시에도 타이머가 흐르도록 유지시키기
- 스톱워치 랩 UITableView Invert 하기
- CoreData의 UndoManager를 활용해 Undo 기능 구현하기
- LiveActivity를 이용해 LockScreen에서 스톱워치 제어하기
