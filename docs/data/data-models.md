# 数据模型

## 1. 核心数据对象

V1.0 包含以下核心数据对象：

User
├── Task
├── KnowledgeDeck
│   └── KnowledgeCard
├── ReviewRecord
├── RestrictedApp
└── UnlockState

## 2. Task

Task 表示用户需要完成的任务。

核心字段：

| 字段 | 说明 |
|---|---|
| id | 任务唯一标识 |
| name | 任务名称 |
| type | 任务类型 |
| target | 任务目标 |
| status | 当前状态 |
| repeatType | 重复规则 |
| createdAt | 创建时间 |


## 3. RestrictedApp

RestrictedApp 表示用户选择由「再玩」控制的 App。

核心信息包括：

| 字段 | 说明 |
|---|---|
| id | 记录唯一标识 |
| appIdentifier | App 的平台标识 |
| platform | 所属平台 |
| createdAt | 添加时间 |


## 4. UnlockState

UnlockState 表示当前受限 App 的解锁状态。

核心状态：

- `Locked`
- `Unlocked`

该状态由 Unlock Rule System 根据当天任务状态计算。

## 5. KnowledgeDeck

| 字段 | 说明 |
|---|---|
| id | 知识库唯一标识 |
| name | 知识库名称 |
| description | 可选说明 |
| createdAt | 创建时间 |
| updatedAt | 更新时间 |

## 6. KnowledgeCard

| 字段 | 说明 |
|---|---|
| id | 卡片唯一标识 |
| deckId | 所属知识库 |
| type | 问答、单选、多选、录音回答、跟读或听力 |
| prompt | 题面或提示 |
| answer | 参考答案 |
| explanation | 可选解析 |
| tags | 标签集合 |
| source | 可选来源 |
| typeConfig | 不同卡片类型的扩展配置 |
| createdAt | 创建时间 |
| updatedAt | 更新时间 |
| nextReviewAt | 下次复习时间 |

`typeConfig` 在持久化层使用带版本的分类结构，避免把所有可选字段混在一个对象中。领域层将其映射为各卡片类型的明确配置。

## 7. ChoiceOption

| 字段 | 说明 |
|---|---|
| id | 稳定选项标识 |
| content | 选项内容 |

正确答案保存选项标识集合，不保存显示位置。

## 8. ReviewRecord

| 字段 | 说明 |
|---|---|
| id | 复习记录唯一标识 |
| cardId | 对应卡片 |
| result | 答错、困难、正确或熟练 |
| answerData | 本次选择、文字或语音判定摘要 |
| reviewedAt | 作答时间 |
| duration | 作答耗时 |
| attemptCount | 本次尝试次数 |
| sessionId | 复习会话标识，用于避免重复累计进度 |

原始录音文件不直接存入 ReviewRecord。记录只保存本地文件引用和必要摘要，并遵循录音保留策略。
