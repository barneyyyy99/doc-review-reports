<u>**目的：旨在为开发者提供开箱即用的示例，让开发者能够在最短时间内看到实际效果，同时可通过运行 Demo 来确认本地开发环境配置正确，为后续正式集成做好准备。**</u>

**1-2 句话介绍产品 Demo 可展示出的核心功能。**

放一张 Demo 跑通后的图片，让用户在跑之前可以看到预期的效果

按照本模版对 Chat iOS Run Demo 文档进行改写后的内容：[https://doc.weixin.qq.com/doc/w3_AV4AdAZ5AFcCNIM59geqpT0yKkIMe?scode=AJEAIQdfAAo5NlTExHAV4AdAZ5AFc](https://doc.weixin.qq.com/doc/w3_AV4AdAZ5AFcCNIM59geqpT0yKkIMe?scode=AJEAIQdfAAo5NlTExHAV4AdAZ5AFc)

## 快速体验 （如有在线 Demo）

如果有在线 Demo 可以直接体验，可以放到这个章节。

## 前提条件

### 开通服务

**章节说明**：列出用户在开始跑通 Demo 前需要获取的 sdkappid、sceretkey、usersig、获取体验版等信息，然后给出开通服务文档链接。

⚠️⚠️⚠️ 把获取 sdkappid 等**具体的步骤和对应的截图**都收口在开通服务文档这一篇即可，其他文档只需要在本章节链接过去。以下为一个示例，可根据产品实际情况进行调整：



请参考 [开通服务](https://write.woa.com/document/141302177829593088)领取 **TUILiveKit** 体验版，并在 [应用管理](https://console.cloud.tencent.com/trtc) 页面获取以下信息:
- **SDKAppID**：应用标识（必填），腾讯云基于 sdkAppId 完成计费统计。

- **SDKSecretKey**：应用密钥，用于初始化配置文件的密钥信息。


### 环境准备

**章节说明**：列出用户在开始集成前必须满足的所有条件和准备工作。包括：

●技术环境要求：开发工具版本、运行环境、依赖项等

一般情况下，跑通 Demo 和集成文档中的开发环境要求应该是一致的，研发同学在写文档时需要 double check。

## 操作步骤

**本节介绍获取 XX Demo 的详细步骤**。

如果有视频教程，可以放在文字操作步骤之前。

### 获取 Demo

介绍获取 Demo 的详细步骤。

一般有两种方式：克隆仓库到本地或者直接下载 demo 项目。多种方式的实现需要**分 Tab 来展示不同的方式。 **<u>**需要介绍 demo 的具体目录位置**</u>**。**

### 配置 Demo

介绍跑通 Demo 需要填的配置信息，如 SDKAppID 和 SDKSecretKey。<u>**步骤中需要明确在哪个文件中填写/修改这些信息**</u>**。**

●如支持多个平台，比如 Flutter，建议使用 Tab 组件区分不同平台的操作步骤。

●明确说明仅用于 Demo 测试，不可用于生产环境

### 编译并运行 Demo

介绍如何编译和运行 Demo 的具体步骤，如具体的终端命令或者是界面操作步骤描述。请勿直接写参考 Demo 的 README.md 文件。 本小节还需介绍<u>**如何使用 Demo 的具体步骤，比如，如何登陆账号发送消息、加入房间开始直播等**</u>。

## 常见问题（可选）

介绍运行 Demo 时常见的问题。包括：

●环境配置问题（如版本不匹配、依赖安装失败）

●网络连接问题（如国内访问速度慢、代理设置）

●平台特定问题 

每个问题都需要提供：问题现象和对应的解决方案

## 联系我们
- 国际站统一使用下列话术：


   如果您在接入或使用过程有任何疑问或者建议，欢迎加入 [Telegram 技术交流群组](https://t.me/+EPk6TMZEZMM5OGY1?s_url=https%3A%2F%2Ftrtc.io)，或[联系我们](https://trtc.io/contact)获取支持。

- 国内站使用下列话术：


   如果您在接入或使用过程有任何疑问或者建议，欢迎 [联系我们](https://cloud.tencent.com/document/product/269/59590) 提交反馈。






