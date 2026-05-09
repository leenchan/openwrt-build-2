#!/bin/sh
CUR_DIR=$(cd $(dirname $0); pwd)

[ -f "$CUR_DIR/.env" ] && source "$CUR_DIR/.env"

getAllTags() {
	curl -skL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${GH_REPO}/tags"
}

deleteTag() {
	curl -X DELETE \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer ${GH_TOKEN}" \
		"https://api.github.com/repos/${GH_REPO}/git/refs/tags/${1}"
}

cleanupTags() {
	TAGS=$(getAllTags | jq -r '.[] | .name')
	for tag in $TAGS; do
		[ "$tag" = "2025.08.14-0218-immortalwrt24.10-6.6-237" ] || {
			echo "Deleting tag: $tag ..."
			deleteTag "$tag"
		}
	done
}

cleanupReleases() {
	RELEASES=$(gh release list --json 'name,tagName,createdAt')
	RELEASE_COUNT=$(echo "$RELEASES" | jq -r '. | length')
	for i in $(seq 0 $((RELEASE_COUNT - 1))); do
		RELEASE=$(echo "$RELEASES" | jq -r ".[$i]")
		RELEASE_NAME=$(echo "$RELEASE" | jq -r '.name')
		RELEASE_TAG=$(echo "$RELEASE" | jq -r '.tagName')
		RELEASE_DATE=$(echo "$RELEASE" | jq -r '.createdAt')
		
		[ "$i" -gt 0 ] && {
			echo "Deleting $RELEASE_NAME ($RELEASE_DATE)"
			gh release delete "$RELEASE_NAME" --cleanup-tag --yes
			# gh tag delete "$RELEASE_TAG" --yes
		}
	done
}

getAllCache() {
	gh cache list --json 'id,key,sizeInBytes,lastAccessedAt'
	# curl -skL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${GH_REPO}/actions/caches"
}

deleteCache() {
	gh cache delete "$1"
}

getAllWorkflowRuns() {
	gh run list --json 'databaseId,name,status,startedAt,displayTitle,number,workflowDatabaseId,workflowName,conclusion'
}

deleteWorkflowRun() {
	gh run delete "$1"
}

deleteAllWorkflowRuns() {
	WORKFLOW_RUNS=$(getAllWorkflowRuns)
	WORKFLOW_RUN_COUNT=$(echo "$WORKFLOW_RUNS" | jq -r '. | length')
	for i in $(seq 0 $((WORKFLOW_RUN_COUNT - 1))); do
		WORKFLOW_RUN=$(echo "$WORKFLOW_RUNS" | jq -r ".[$i]")
		WORKFLOW_RUN_ID=$(echo "$WORKFLOW_RUN" | jq -r '.databaseId')
		deleteWorkflowRun "$WORKFLOW_RUN_ID"
	done
}

# deleteAllWorkflowRuns

cleanupReleases

