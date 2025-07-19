# Contributing to ZeroShift

Thank you for your interest in contributing to ZeroShift! This document provides guidelines and information for contributors.

## Development Workflow

### Branch Strategy

We follow a Git Flow branching strategy:

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Individual feature branches
- **hotfix/***: Critical bug fixes

### Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/ZeroShift.git
   cd ZeroShift
   ```

2. **Create a feature branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards
   - Add tests for new functionality
   - Update documentation

4. **Test your changes**
   ```bash
   make test
   make docker-build
   make docker-up
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

6. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### Go Code

- Follow [Effective Go](https://golang.org/doc/effective_go.html)
- Use `gofmt` for formatting
- Write tests for all new functionality
- Use meaningful variable and function names
- Add comments for complex logic

### Docker

- Use multi-stage builds
- Minimize image size
- Use specific version tags
- Include health checks
- Run as non-root user

### Documentation

- Update README.md for user-facing changes
- Update DEPLOYMENT.md for deployment changes
- Use clear, concise language
- Include examples where appropriate

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests with coverage
go test -cover ./...

# Run tests for specific service
cd blue && go test -v
cd green && go test -v
```

### Test Requirements

- All new code must have tests
- Maintain >80% code coverage
- Include integration tests for API endpoints
- Test error conditions and edge cases

## Pull Request Process

1. **Create a Pull Request** from your feature branch to `develop`
2. **Fill out the PR template** completely
3. **Ensure all tests pass** in CI/CD
4. **Request review** from maintainers
5. **Address feedback** and make requested changes
6. **Merge to develop** after approval

### PR Guidelines

- Keep PRs focused and small
- Include clear description of changes
- Link related issues
- Add screenshots for UI changes
- Update documentation as needed

## Code Review

### Review Checklist

- [ ] Code follows project standards
- [ ] Tests are included and pass
- [ ] Documentation is updated
- [ ] No security issues introduced
- [ ] Performance impact considered
- [ ] Error handling is appropriate

### Review Process

1. Automated checks must pass
2. At least one maintainer approval required
3. Address all review comments
4. Maintainers will merge after approval

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Create release branch** from `develop`
2. **Update version** in relevant files
3. **Run full test suite**
4. **Create release notes**
5. **Merge to main** via PR
6. **Tag release** on GitHub
7. **Deploy to production**

## Issue Reporting

### Bug Reports

When reporting bugs, please include:

- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Go version, etc.)
- Relevant logs or error messages

### Feature Requests

For feature requests, include:

- Clear description of the feature
- Use cases and benefits
- Implementation suggestions (if any)
- Priority level

## Communication

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Security**: Report security issues privately to maintainers

## Getting Help

- Check existing issues and discussions
- Review documentation in README.md
- Ask questions in GitHub Discussions
- Contact maintainers for urgent issues

## Code of Conduct

- Be respectful and inclusive
- Focus on technical merit
- Help others learn and grow
- Follow project guidelines

Thank you for contributing to ZeroShift! 