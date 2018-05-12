node {
    git 'https://github.com/abeego/issues-tracker-ci.git'

    try {
        stage 'Run unit/integration tests'
        sh 'make test'

        stage 'Build application artefacts'
        sh 'make build'

        stage 'Create release environment and run acceptance tests'
        sh 'make release'

        stage 'Tag and publish release image'
        sh 'make tag latest \$(git rev-parse --short HEAD) \$(git tag --points-at HEAD)'
        sh 'make buildtag master \$(git tag --points-at HEAD)'
        sh 'docker login -u \${DOCKER_USER} -p \${DOCKER_PASSWORD}'
        sh 'make publish'
    }
    finally {
        stage 'Collect test reports'
        step([$class: 'JUnitResultArchiver', testResults: '**/reports/*.xml'])

        stage 'Clean up'
        sh 'make clean'
        sh 'make logout'
    }
}
