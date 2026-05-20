const csv = (value) =>
  value
    ? value
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean)
    : undefined;

const envCsv = (name, fallback) =>
  Object.hasOwn(process.env, name) ? (csv(process.env[name]) ?? []) : fallback;

const gitlabMentions = (users) =>
  users?.map((user) => (user.startsWith('@') ? user : `@${user}`));

const dashboardMentions = gitlabMentions(
  envCsv('RENOVATE_DASHBOARD_MENTIONS', ['g1lom']),
);

module.exports = {
  platform: 'gitlab',
  endpoint: 'https://gitlab.g1lom.xyz/api/v4/',

  autodiscover: true,
  autodiscoverFilter: csv(process.env.RENOVATE_AUTODISCOVER_FILTER) ?? ['g1lom/*'],

  onboarding: true,
  requireConfig: 'optional',
  dependencyDashboard: true,
  minimumReleaseAge: '2 days',
  internalChecksFilter: 'strict',
  dependencyDashboardAutoclose: true,
  dependencyDashboardHeader: dashboardMentions?.length
    ? `${dashboardMentions.join(' ')}\n\nThis issue lists Renovate updates and detected dependencies. Read the [Dependency Dashboard](https://docs.renovatebot.com/key-concepts/dashboard/) docs to learn more.`
    : undefined,

  extends: ['config:recommended'],

  gitAuthor:
    process.env.RENOVATE_GIT_AUTHOR ??
    'Renovate Bot <plain.rose9051@fastmail.com>',
  labels: ['dependencies', 'renovate'],
  assignees: envCsv('RENOVATE_ASSIGNEES', ['g1lom']),
  reviewers: envCsv('RENOVATE_REVIEWERS', ['g1lom']),

  prConcurrentLimit: 5,
  branchConcurrentLimit: 10,

  packageRules: [
    {
      description: 'Group non-major Docker image updates',
      matchDatasources: ['docker'],
      matchUpdateTypes: ['minor', 'patch', 'digest'],
      groupName: 'docker image updates',
    },
    {
      description: 'Group non-major Python dependency updates',
      matchDatasources: ['pypi'],
      matchUpdateTypes: ['minor', 'patch'],
      groupName: 'python dependency updates',
    },
  ],
};
