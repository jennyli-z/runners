FROM milvusdb/krte:20211213-dcc15e9
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
RUN mkdir -p /opt/hostedtoolcache

ARG GH_RUNNER_VERSION="2.299.1"
ARG TARGET_ARCH="x64"
RUN groupadd -g 121 runner \
    && useradd -mr -d /home/runner -u 1001 -g 121 runner \
    && usermod -aG sudo runner \
    && usermod -aG docker runner \
    && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers


SHELL ["/bin/bash", "-o", "pipefail", "-c"]


WORKDIR /actions-runner

COPY install_actions.sh /actions-runner

RUN chmod +x /actions-runner/install_actions.sh \
  && /actions-runner/install_actions.sh ${GH_RUNNER_VERSION} ${TARGET_ARCH} \
  && rm /actions-runner/install_actions.sh \
  && chown runner /_work /actions-runner /opt/hostedtoolcache

COPY token.sh entrypoint.sh /
RUN chmod +x /token.sh /entrypoint.sh

ENV RUNNER_SCOPE=org
ENV ORG_NAME=zilliztech

USER runner

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./run.sh"]