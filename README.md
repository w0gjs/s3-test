# **S3 버킷 아키텍처 구성**

## **버킷 설계 원칙**

### **1. 데이터 성격별 분리**

서로 성격이 다른 데이터를 한 버킷에 섞어 저장하지 않는다.

- 감사 로그
- 전자금융거래기록
- AML 자료
- 백업 자료
- Athena 조회 결과
- 컴플라이언스 자료

이렇게 분리해야 접근통제와 보관정책을 명확하게 적용할 수 있다.

---

### **2. 보관 기간별 분리**

법령상 보관 기간이 다른 데이터는 동일한 버킷에 저장하지 않는다.

- 1년 보관 대상
- 5년 보관 대상

보관 기간이 다른 데이터를 같은 버킷에 저장하면 동일한 Lifecycle 정책을 적용하기 어렵다.

---

### **3. 원본 데이터와 조회 결과 분리**

Athena 조회 결과는 원본 데이터와 분리하여 저장한다.

특히 Athena 조회 결과에는 개인정보 전자금융거래기록 AML 자료가 포함될 수 있으므로

조회 결과도 Prefix 단위로 다시 구분하여 관리한다.

---

### **4. 감사 및 확장성 고려**

월간 감사 기록

ISMS-P 점검 결과

규제 준수 점검 자료

이상 접근 탐지 결과 등

감사와 컴플라이언스 확장을 위한 자료를 별도로 저장할 수 있도록 설계한다.

---

## **계정 및 접근통제 원칙**

### **Root Account**

조직 및 계정 관리 전용 계정으로 사용한다.

실제 업무 데이터 버킷 접근 주체로 사용하지 않는다.

### **Audit Account**

감사와 보안 점검 전용 계정으로 사용한다.

감사 로그 및 컴플라이언스 자료를 중앙 관리한다.

### **Production Account**

실제 운영 서비스 계정으로 사용한다.

전자금융거래기록 AML 자료 백업 Athena 조회 결과 등 운영 데이터를 저장한다.

### **Development Account**

개발 및 테스트 계정으로 사용한다.

운영 원본 데이터 저장은 금지하고 테스트 목적의 비운영 데이터만 저장한다.

---

## **공통 설정**

- 모든 버킷은 퍼블릭 액세스를 차단한다
- 서버 측 암호화는 SSE-KMS를 적용한다
- Lifecycle 정책은 법적 보관 기간에 따라 설정한다
- Athena 결과 버킷은 Prefix 기준으로 보관 정책을 분리한다
- 버전 관리는 필요한 버킷에 한해 검토 적용한다

---

# **버킷 구성**

## **1. audit-log**

### **용도**

감사 및 운영 목적의 로그를 중앙 수집하는 버킷

### **저장 데이터**

- CloudTrail
- VPC Flow Logs
- WAF Logs
- 시스템 로그
- 관리자 접근기록
- IP 접속기록

### **계정 배치**

**Audit Account**

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account 및 Development Account의 승인된 로그 적재 서비스
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

1년 이상

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 Glacier

---

## **2. regulated-records-1y**

### **용도**

1년 보관 대상 기록을 저장하는 버킷

### **저장 데이터**

- 1년 보관 대상 전자금융거래 관련 기록
- 단기 보관 대상 승인 및 처리 기록
- 법령상 1년 보관 기준이 적용되는 업무 기록

### **계정 배치**

**Production Account**

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 승인된 애플리케이션
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

1년

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 삭제

---

## **3. regulated-records-5y**

### **용도**

5년 보관 대상 규제 기록을 저장하는 버킷

### **저장 데이터**

- 5년 보관 대상 전자금융거래기록
- 지급인 출금동의 기록
- 거래 상대방 확인 기록
- 오류 정정 및 분쟁 대응용 거래 추적 기록

### **계정 배치**

**Production Account**

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 승인된 애플리케이션
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

5년

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 Glacier
- 5년 후 삭제

---

## **4. aml**

### **용도**

자금세탁방지 관련 자료를 저장하는 버킷

### **저장 데이터**

- 고객확인 자료
- STR 및 CTR 자료
- AML 업무 수행 증적
- 의심거래 분석 기록
- 내부 점검 기록

### **계정 배치**

**Production Account**

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 AML 처리 시스템
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

5년

### **Lifecycle**

- Standard
- 180일 후 Standard-IA
- 1년 후 Glacier
- 5년 후 삭제

---

## **5. backups**

### **용도**

백업 자료 및 재해복구용 예비 자료를 저장하는 버킷

### **저장 데이터**

- DB 백업
- 운영체계 백업
- 설정 백업
- IaC 산출물 백업

### **계정 배치**

**Production Account**

### **접근제어**

- 읽기 : Production Account의 승인된 운영 주체
- 쓰기 : Production Account의 백업 자동화
- 삭제 : Production Account의 승인된 운영 주체만 제한 허용

### **보관 기간**

업무 중요도와 복구 정책에 따라 관리

### **Lifecycle**

- Standard
- 30일 후 Standard-IA
- 180일 후 Glacier

---

## **6. athena-results**

### **용도**

Athena 조회 결과를 저장하는 버킷

### **저장 데이터**

- 운영 로그 조회 결과
- 보안 감사 분석 결과
- 개인정보 조회 결과
- 전자금융거래기록 조회 결과
- AML 조회 결과
- 컴플라이언스 보고용 추출 결과

### **계정 배치**

**Production Account**

Athena 조회 결과는 원본 데이터와 분리 저장하며

조회 결과에 포함된 데이터 성격에 따라 Prefix 단위로 다시 구분한다.

### **Lifecycle**

Prefix별 분리 관리

---

### **6-1. ops/**

### **용도**

일반 운영 분석 결과 저장

### **접근제어**

- 읽기 : Production Account
- 쓰기 : Production Account의 Athena 운영 Workgroup
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

30일

### **Lifecycle**

- 30일 보관 후 삭제

---

### **6-2. sc-audit/**

### **용도**

보안 감사 분석 결과 저장

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 Athena 감사 분석 주체
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

1년 이상

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 Glacier

---

### **6-3. pi-access/**

### **용도**

개인정보 조회 결과 저장

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 승인된 Athena 조회 주체
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

최소 1년 이상

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 Glacier

---

### **6-4. transactions/**

### **용도**

전자금융거래기록 조회 결과 저장

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 Athena 거래기록 분석 주체
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

원본 기록 보관 기준 준용

### **Lifecycle**

- 원본 기록 보관 기준에 따라 별도 설정

---

### **6-5. aml-result/**

### **용도**

AML 조회 결과 저장

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 Athena AML 분석 주체
- 삭제 : 직접 삭제 금지 후 Lifecycle 정책으로 관리

### **보관 기간**

AML 자료 보관 기준 준용

### **Lifecycle**

- AML 자료 보관 기준에 따라 별도 설정

---

### **6-6. compliance-result/**

### **용도**

보고서 제출용 추출 결과 저장

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Production Account의 Athena 컴플라이언스 분석 주체
- 삭제 : 직접 삭제보다 compliance 버킷 이관을 우선 적용

### **보관 기간**

제출 및 이관 시점까지 보관

### **Lifecycle**

- 필요 시 compliance 버킷으로 이관 후 원본 삭제

---

## **7. compliance**

### **용도**

감사 및 규제 준수 자료를 저장하는 버킷

### **저장 데이터**

- 월간 감사보고서
- ISMS-P 점검 결과
- 규제 준수 점검표
- 제출용 증거자료
- 컴플라이언스 산출물

### **계정 배치**

**Audit Account**

### **접근제어**

- 읽기 : Audit Account
- 쓰기 : Audit Account
- 삭제 : Audit Account의 승인된 주체만 허용

### **보관 기간**

업무 및 감사 정책에 따라 관리

### **Lifecycle**

- Standard
- 90일 후 Standard-IA
- 1년 후 Glacier

---

## **계정별 권한 정리**

| 계정 | 권한 및 역할 |
|------|------------|
| **Root Account** | 조직 및 계정 관리 전용 |
| **Audit Account** | audit-log, compliance 및 감사 목적 조회 결과 접근 |
| **Production Account** | 전자금융거래기록, AML, 백업, Athena 결과 저장 |
| **Development Account** | 운영 원본 데이터 저장 금지, 테스트 목적 데이터만 사용 |

---

## **아키텍처 개요**

```
Development Account
    └─ 비운영 테스트 데이터

                    ↓
                    
Production Account
├─ regulated-records-1y (1년 보관)
├─ regulated-records-5y (5년 보관)
├─ aml (AML 자료, 5년 보관)
├─ backups (DB/설정 백업)
└─ athena-results (조회 결과)
   ├─ ops/ (운영 분석)
   ├─ sc-audit/ (보안 감사)
   ├─ pi-access/ (개인정보)
   ├─ transactions/ (거래기록)
   ├─ aml-result/ (AML 분석)
   └─ compliance-result/ (컴플라이언스)

                    ↓
                    
Audit Account
├─ audit-log (감사 로그 중앙 수집)
│  ├─ CloudTrail
│  ├─ VPC Flow Logs
│  ├─ WAF Logs
│  └─ System Logs
└─ compliance (규제 준수 자료)
   ├─ 월간 감사보고서
   ├─ ISMS-P 점검 결과
   └─ 규제 준수 점검표
```

---

# **Terraform 사용 방법**

## **설정**

1. `terraform.tfvars.example` 을 참고하여 `terraform.tfvars` 파일 생성
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. `terraform.tfvars` 에 실제 설정값 입력 (AWS 계정 정보, 리전 등)

## **주의사항**

⚠️ **민감 정보 보호:**
- `terraform.tfvars` - AWS 계정 정보, 구성 값 포함 → **버전 관리에서 제외됨**
- `*.tfstate` - Terraform 상태 파일 → **버전 관리에서 제외됨**
- `.gitignore` 에 민감 파일이 등재되어 있으므로 실수로 커밋되지 않습니다

## **실행**

```bash
# Terraform 초기화
terraform init

# 계획 검토
terraform plan

# 리소스 생성
terraform apply

# 리소스 삭제
terraform destroy
```

## **파일 구조**

- `provider.tf` - AWS 프로바이더 설정
- `variables.tf` - 변수 정의
- `locals.tf` - 로컬 변수
- `kms.tf` - KMS 암호화 키
- `s3_*.tf` - 각 S3 버킷 정의
- `outputs.tf` - 출력값
# s3-test
# s3-test
