package io.fabric8.launcher.service.github.api;

import io.fabric8.launcher.base.identity.Identity;

/**
 * A factory for the {@link GitHubService} instance.
 *
 * @author <a href="mailto:alr@redhat.com">Andrew Lee Rubinger</a>
 * @author <a href="mailto:xcoulon@redhat.com">Xavier Coulon</a>
 */
public interface GitHubServiceFactory {

    /**
     * Creates a new {@link GitHubService} with the default authentication.
     *
     * @return the created {@link GitHubService}
     */
    GitHubService create();

    /**
     * Creates a new {@link GitHubService} with the specified,
     * required personal access token.
     *
     * @param identity
     * @return the created {@link GitHubService}
     * @throws IllegalArgumentException If the {@code githubToken} is not specified
     */
    GitHubService create(Identity identity);


    /**
     * Checks if the default identity for this service is set
     *
     * @return true if the default Github identities are set
     */
    boolean isDefaultIdentitySet();
}